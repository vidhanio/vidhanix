{
  config,
  flake-parts-lib,
  lib,
  ...
}:
let
  buildRunners = {
    "x86_64-linux" = "ubuntu-latest";
    "aarch64-linux" = "ubuntu-26.04-arm";
  };

  packageBuilds = lib.concatLists (
    lib.mapAttrsToList (
      system: packages:
      lib.mapAttrsToList (pkg: package: {
        inherit pkg system;
        runner = buildRunners.${system};
        inherit (package) drvPath;
      }) (lib.filterAttrs (_pkg: package: lib.elem system (package.meta.platforms or [ ])) packages)
    ) (lib.filterAttrs (system: _packages: builtins.hasAttr system buildRunners) config.flake.packages)
  );

  systemBuilds = lib.mapAttrsToList (
    name: host:
    let
      system = host.config.nixpkgs.hostPlatform.system;
    in
    {
      inherit name system;
      attr = "nixosConfigurations." + name + ".config.system.build.toplevel";
      runner = buildRunners.${system};
      drvPath = host.config.system.build.toplevel.drvPath;
    }
  ) config.flake.nixosConfigurations;
in
{
  config.flake.ciBuildMatrices = {
    packages = packageBuilds;
    systems = systemBuilds;
  };
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    { config, ... }:
    let
      inherit (config.files.lib.github)
        ghExpr
        just
        checkout
        setupNix
        ;
      # Matrix evaluation never builds outputs, so it needs no cache push token.
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
                  printf 'packages=%s\n' "$(nix eval --json .#ciBuildMatrices.packages)" >> "$GITHUB_OUTPUT"
                  printf 'systems=%s\n' "$(nix eval --json .#ciBuildMatrices.systems)" >> "$GITHUB_OUTPUT"
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
              setupNix
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
