{ flake-parts-lib, ... }:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    { config, ... }:
    let
      inherit (config.workflowCommon) ghExpr nixJob updatablePackages;
    in
    {
      config.files.workflows.update-packages = {
        name = "update packages";

        on = {
          push.branches = [ "main" ];
          schedule = [
            { cron = "0 9 * * *"; }
          ];
        };

        permissions = {
          actions = "write";
          contents = "write";
          pull-requests = "write";
        };

        concurrency = {
          group = "update-packages";
          cancel-in-progress = false;
        };

        jobs.update = nixJob // {
          strategy = {
            matrix.pkg = updatablePackages;
            fail-fast = false;
          };
          "with" = {
            name = "update package: ${ghExpr "matrix.pkg"}";
            command = "bash .github/scripts/update-package.sh \"$PACKAGE\"";
            ref = "main";
            fetch-depth = 0;
            persist-credentials = false;
            package = ghExpr "matrix.pkg";
            create-package-pr = true;
          };
          secrets = nixJob.secrets // {
            PACKAGE_UPDATE_TOKEN = ghExpr "secrets.PACKAGE_UPDATE_TOKEN";
          };
        };
      };
    }
  );
}
