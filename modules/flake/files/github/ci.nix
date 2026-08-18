{ flake-parts-lib, ... }:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    { config, ... }:
    let
      inherit (config.files.lib.github)
        ghExpr
        hosts
        just
        checkout
        setupNix
        ;
    in
    {
      config.files.github.workflows.ci = {
        name = "ci";

        on = {
          push = { };
          pull_request = { };
        };

        permissions = {
          # the store cache save needs actions: write
          contents = "read";
          actions = "write";
        };

        concurrency = {
          group = ghExpr "github.ref";
          cancel-in-progress = true;
        };

        jobs = {
          check-formatting = {
            name = "check formatting";
            runs-on = "ubuntu-latest";
            steps = [
              checkout
              setupNix
              {
                name = "check formatting";
                run = "${just} fmt --ci";
              }
            ];
          };

          check-generated-files = {
            name = "check generated files";
            runs-on = "ubuntu-latest";
            steps = [
              checkout
              setupNix
              {
                name = "generate files";
                run = "${just} generate";
              }
              {
                name = "check diff";
                run = "git diff --exit-code";
              }
            ];
          };

          eval-systems = {
            name = "eval system: ${ghExpr "matrix.name"}";
            runs-on = "ubuntu-latest";
            strategy = {
              matrix.include = hosts;
              fail-fast = false;
            };
            steps = [
              checkout
              setupNix
              {
                name = "eval system";
                # forcing the toplevel drvPath evaluates the whole system
                # config without building anything.
                run = "nix eval .#${ghExpr "matrix.attr"} --raw";
              }
            ];
          };

          build-packages = {
            name = "build package: ${ghExpr "matrix.pkg"}";
            runs-on = "ubuntu-latest";
            strategy = {
              matrix.pkg = builtins.attrNames config.packages;
              fail-fast = false;
            };
            steps = [
              checkout
              setupNix
              {
                name = "build package";
                run = "nix build .#${ghExpr "matrix.pkg"} --print-build-logs";
              }
            ];
          };
        };
      };
    }
  );
}
