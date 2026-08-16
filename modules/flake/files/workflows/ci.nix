{ flake-parts-lib, ... }:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    { config, ... }:
    let
      inherit (config.workflowCommon)
        ghExpr
        hosts
        just
        nixJob
        ;
    in
    {
      config.files.workflows.ci = {
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
          check-formatting = nixJob // {
            "with" = {
              name = "check formatting";
              command = "${just} fmt --ci";
            };
          };

          check-generated-files = nixJob // {
            "with" = {
              name = "check generated files";
              command = "${just} generate && git diff --exit-code";
            };
          };

          eval-systems = nixJob // {
            strategy = {
              matrix.include = hosts;
              fail-fast = false;
            };
            "with" = {
              name = "eval system: ${ghExpr "matrix.name"}";
              command = "nix eval .#${ghExpr "matrix.attr"} --raw";
            };
          };

          build-packages = nixJob // {
            strategy = {
              matrix.pkg = builtins.attrNames config.packages;
              fail-fast = false;
            };
            "with" = {
              name = "build package: ${ghExpr "matrix.pkg"}";
              command = "nix build .#${ghExpr "matrix.pkg"} --print-build-logs";
            };
          };
        };
      };
    }
  );
}
