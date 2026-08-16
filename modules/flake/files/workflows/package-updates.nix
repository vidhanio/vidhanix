{ flake-parts-lib, ... }:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    { config, ... }:
    let
      inherit (config.workflowCommon) ghExpr nixStepsOnMain updatablePackages;
    in
    {
      config.workflows.update-packages = {
        name = "update packages";

        on = {
          push.branches = [ "main" ];
          schedule = [
            { cron = "0 9 * * 1"; }
          ];
        };

        permissions = {
          actions = "write";
          contents = "write";
          pull-requests = "write";
        };

        concurrency = {
          group = "update-packages";
          "cancel-in-progress" = false;
        };

        jobs.update = {
          name = "update package: ${ghExpr "matrix.pkg"}";
          "runs-on" = "ubuntu-latest";
          strategy = {
            matrix.pkg = updatablePackages;
            "fail-fast" = false;
          };
          steps = nixStepsOnMain ++ [
            {
              name = "update package";
              id = "update";
              env.PACKAGE = ghExpr "matrix.pkg";
              run = "bash .github/scripts/update-package.sh \"$PACKAGE\"";
            }
            {
              # the fixed branch is rebased on main and closed when it has no diff.
              name = "create pull request";
              uses = "peter-evans/create-pull-request@v8";
              "with" = {
                base = "main";
                # GITHUB_TOKEN pushes do not trigger the pull request workflow.
                token = ghExpr "secrets.PACKAGE_UPDATE_TOKEN";
                branch = "package-updates/${ghExpr "matrix.pkg"}";
                "commit-message" =
                  "chore(packages): bump ${ghExpr "matrix.pkg"} from ${ghExpr "steps.update.outputs.before"} to ${ghExpr "steps.update.outputs.after"}";
                "delete-branch" = true;
                title = "chore(packages): bump ${ghExpr "matrix.pkg"} from ${ghExpr "steps.update.outputs.before"} to ${ghExpr "steps.update.outputs.after"}";
                body = ghExpr "steps.update.outputs.body";
              };
            }
          ];
        };
      };
    }
  );
}
