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
      lib.mapAttrsToList (pkg: _package: {
        inherit pkg system;
        runner = buildRunners.${system};
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
    }
  ) config.flake.nixosConfigurations;
in
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
            strategy = {
              matrix.include = systemBuilds;
              fail-fast = false;
            };
            concurrency = {
              group = ghExpr "format('nix-{0}', matrix.name)";
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
            strategy = {
              matrix.include = packageBuilds;
              fail-fast = false;
            };
            concurrency = {
              group = ghExpr "format('nix-{0}', matrix.pkg)";
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
