{ flake-parts-lib, ... }:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    { config, ... }:
    let
      inherit (config.workflowCommon) ghExpr nixJob;
    in
    {
      config.files.workflows.dependabot-sync = {
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

        jobs.sync = nixJob // {
          # only the base workflow runs; the script treats the PR as data.
          "if" = "github.event.pull_request.user.login=='dependabot[bot]'";
          "with" = {
            name = "sync dependabot actions";
            command = "python3 .github/scripts/dependabot-sync.py";
            ref = ghExpr "github.event.pull_request.base.sha";
            fetch-depth = 0;
            persist-credentials = false;
            base-ref = ghExpr "github.event.pull_request.base.ref";
            base-sha = ghExpr "github.event.pull_request.base.sha";
            head-ref = ghExpr "github.event.pull_request.head.ref";
            head-repo = ghExpr "github.event.pull_request.head.repo.full_name";
            head-sha = ghExpr "github.event.pull_request.head.sha";
            pr-number = ghExpr "github.event.pull_request.number";
          };
          secrets = nixJob.secrets // {
            PACKAGE_UPDATE_TOKEN = ghExpr "secrets.PACKAGE_UPDATE_TOKEN";
          };
        };
      };
    }
  );
}
