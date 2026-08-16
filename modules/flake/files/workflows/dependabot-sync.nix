{ flake-parts-lib, ... }:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    { config, ... }:
    let
      inherit (config.workflowCommon) ghExpr nixStepsOnBase;
    in
    {
      config.workflows.dependabot-sync = {
        name = "sync dependabot actions";

        on.pull_request_target = {
          branches = [ "main" ];
          types = [
            "opened"
            "synchronize"
            "reopened"
          ];
        };

        permissions = {
          actions = "write";
          contents = "write";
          pull-requests = "write";
        };

        jobs.sync = {
          # only the base workflow runs; the script treats the PR as data.
          "if" = "github.event.pull_request.user.login=='dependabot[bot]'";
          name = "sync dependabot actions";
          "runs-on" = "ubuntu-latest";
          steps = nixStepsOnBase ++ [
            {
              name = "sync action updates";
              env = {
                BASE_REF = ghExpr "github.event.pull_request.base.ref";
                BASE_SHA = ghExpr "github.event.pull_request.base.sha";
                HEAD_REF = ghExpr "github.event.pull_request.head.ref";
                HEAD_REPO = ghExpr "github.event.pull_request.head.repo.full_name";
                HEAD_SHA = ghExpr "github.event.pull_request.head.sha";
                PACKAGE_UPDATE_TOKEN = ghExpr "secrets.PACKAGE_UPDATE_TOKEN";
                PR_NUMBER = ghExpr "github.event.pull_request.number";
              };
              run = "python3 .github/scripts/dependabot-sync.py";
            }
          ];
        };
      };
    }
  );
}
