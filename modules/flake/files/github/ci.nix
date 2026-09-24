{ flake-parts-lib, ... }:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    { config, ... }:
    let
      inherit (config.files.lib.github)
        ghExpr
        just
        checkout
        setupNix
        ;
      # System closures can include licensed fonts; never publish those closures.
      setupNixReadOnly = setupNix // {
        "with" = setupNix."with" // {
          cachix-auth-token = "";
        };
      };

    in
    {
      config.files.github.workflows.ci = {
        name = "CI";

        on = {
          push = { };
          pull_request = { };
        };

        permissions = {
          # the store cache save needs actions: write
          contents = "read";
          actions = "write";
        };

        jobs = {

          plan-builds = {
            name = "Plan Builds";
            runs-on = "ubuntu-latest";
            outputs = {
              packages = ghExpr "steps.build-matrices.outputs.packages";
              systems = ghExpr "steps.build-matrices.outputs.systems";
            };
            steps = [
              checkout
              setupNixReadOnly
              {
                name = "Build Matrices";
                id = "build-matrices";
                run = ''
                  printf 'packages=%s\n' "$(
                    nix eval --json .#packages --apply '
                      packages:
                      builtins.concatLists (builtins.map (system:
                        let systemPackages = builtins.getAttr system packages;
                        in builtins.map (pkg:
                          let package = builtins.getAttr pkg systemPackages;
                          in {
                            inherit pkg system;
                            runner = builtins.getAttr system {
                              "x86_64-linux" = "ubuntu-latest";
                              "aarch64-linux" = "ubuntu-26.04-arm";
                            };
                            drvPath = package.drvPath;
                          }
                        ) (builtins.filter (pkg:
                          let package = builtins.getAttr pkg systemPackages;
                          in builtins.elem system (package.meta.platforms or [ ])
                        ) (builtins.attrNames systemPackages))
                      ) [ "x86_64-linux" "aarch64-linux" ])'
                  )" >> "$GITHUB_OUTPUT"
                  printf 'systems=%s\n' "$(
                    nix eval --json .#nixosConfigurations --apply '
                      hosts:
                      builtins.map (name:
                        let
                          host = builtins.getAttr name hosts;
                          system = host.config.nixpkgs.hostPlatform.system;
                        in {
                          inherit name system;
                          attr = "nixosConfigurations." + name + ".config.system.build.toplevel";
                          runner = builtins.getAttr system {
                            "x86_64-linux" = "ubuntu-latest";
                            "aarch64-linux" = "ubuntu-26.04-arm";
                          };
                          drvPath = host.config.system.build.toplevel.drvPath;
                        }
                      ) (builtins.attrNames hosts)'
                  )" >> "$GITHUB_OUTPUT"
                '';
              }
            ];
          };
          check-formatting = {
            name = "Check Formatting";
            runs-on = "ubuntu-latest";
            steps = [
              checkout
              setupNix
              {
                name = "Check Formatting";
                run = "${just} fmt --ci";
              }
            ];
          };

          check-generated-files = {
            name = "Check Generated Files";
            runs-on = "ubuntu-latest";
            steps = [
              checkout
              setupNix
              {
                name = "Generate Files";
                run = "${just} generate";
              }
              {
                name = "Check Diff";
                run = "git diff --exit-code";
              }
            ];
          };

          build-systems = {
            name = "Build System (${ghExpr "matrix.system"}): ${ghExpr "matrix.name"}";
            runs-on = ghExpr "matrix.runner";
            needs = "plan-builds";
            strategy = {
              matrix.include = ghExpr "fromJSON(needs.plan-builds.outputs.systems)";
              fail-fast = false;
            };
            concurrency = {
              group = ghExpr "format('nix-{0}', matrix.drvPath)";
              cancel-in-progress = false;
              queue = "max";
            };
            steps = [
              checkout
              setupNixReadOnly
              {
                name = "Build System";
                run = "nix build .#${ghExpr "matrix.attr"} --print-build-logs";
              }
            ];
          };

          build-packages = {
            name = "Build Package (${ghExpr "matrix.system"}): ${ghExpr "matrix.pkg"}";
            runs-on = ghExpr "matrix.runner";
            needs = "plan-builds";
            strategy = {
              matrix.include = ghExpr "fromJSON(needs.plan-builds.outputs.packages)";
              fail-fast = false;
            };
            concurrency = {
              group = ghExpr "format('nix-{0}', matrix.drvPath)";
              cancel-in-progress = false;
              queue = "max";
            };
            steps = [
              checkout
              setupNix
              {
                name = "Build Package";
                run = "nix build .#${ghExpr "matrix.pkg"} --print-build-logs";
              }
            ];
          };
        };
      };
    }
  );
}
