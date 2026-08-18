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

        concurrency = {
          group = ghExpr "github.ref";
          cancel-in-progress = true;
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

          eval-systems = {
            name = "Evaluate System: ${ghExpr "matrix.name"}";
            runs-on = "ubuntu-latest";
            strategy = {
              matrix.include = hosts;
              fail-fast = false;
            };
            steps = [
              checkout
              setupNix
              {
                name = "Evaluate System";
                # forcing the toplevel drvPath evaluates the whole system
                # config without building anything.
                run = "nix eval .#${ghExpr "matrix.attr"} --raw";
              }
            ];
          };

          build-packages = {
            name = "Build Package: ${ghExpr "matrix.pkg"}";
            runs-on = "ubuntu-latest";
            strategy = {
              matrix.pkg = builtins.attrNames config.packages;
              fail-fast = false;
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
