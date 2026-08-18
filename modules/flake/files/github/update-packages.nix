{ flake-parts-lib, ... }:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    { config, ... }:
    let
      inherit (config.files.lib.github)
        ghExpr
        updatablePackages
        checkout
        setupNix
        createAppToken
        ;
    in
    {
      config.files.github.workflows.update-packages = {
        name = "Update packages";

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

        jobs.update = {
          name = "Update package: ${ghExpr "matrix.pkg"}";
          runs-on = "ubuntu-latest";
          strategy = {
            matrix.pkg = updatablePackages;
            fail-fast = false;
          };
          steps = [
            checkout
            setupNix
            {
              name = "Update package";
              id = "update";
              env.PACKAGE = ghExpr "matrix.pkg";
              run = "bash .github/scripts/update-package.sh \"$PACKAGE\"";
            }
            createAppToken
            {
              # the fixed branch is rebased on main and closed when it has no diff.
              name = "Create pull request";
              uses = "peter-evans/create-pull-request@v8";
              "with" = {
                token = ghExpr "steps.app-token.outputs.token";
                branch = "packages/${ghExpr "matrix.pkg"}";
                commit-message = "chore(packages): bump ${ghExpr "matrix.pkg"} from ${ghExpr "steps.update.outputs.before"} to ${ghExpr "steps.update.outputs.after"}";
                delete-branch = true;
                title = "chore(packages): bump ${ghExpr "matrix.pkg"} from ${ghExpr "steps.update.outputs.before"} to ${ghExpr "steps.update.outputs.after"}";
                body = ghExpr "steps.update.outputs.body";
                sign-commits = true;
              };
            }
          ];
        };
      };
    }
  );
}
