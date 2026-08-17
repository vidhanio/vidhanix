{ flake-parts-lib, ... }:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    { config, ... }:
    let
      inherit (config.workflowCommon)
        ghExpr
        deepCheckoutBase
        createAppToken
        ;
    in
    {
      config.files.workflows.sync-action-updates = {
        name = "sync action updates";

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
          # only dependabot github_actions PRs; the script treats the PR as data.
          "if" =
            "github.event.pull_request.user.login=='dependabot[bot]' && startsWith(github.event.pull_request.head.ref,'dependabot/github_actions/')";
          name = "sync action updates";
          runs-on = "ubuntu-latest";
          steps = [
            deepCheckoutBase
            createAppToken
            {
              name = "sync action updates";
              # skips the run triggered by our own sync commit (the loop).
              "if" = "github.event.sender.login != concat(steps.app-token.outputs.app-slug, '[bot]')";
              env = {
                BASE_REF = ghExpr "github.event.pull_request.base.ref";
                BASE_SHA = ghExpr "github.event.pull_request.base.sha";
                HEAD_REF = ghExpr "github.event.pull_request.head.ref";
                HEAD_REPO = ghExpr "github.event.pull_request.head.repo.full_name";
                HEAD_SHA = ghExpr "github.event.pull_request.head.sha";
                PR_NUMBER = ghExpr "github.event.pull_request.number";
              };
              run = "python3 .github/scripts/sync-action-updates.py";
            }
            {
              name = "commit";
              "if" = "github.event.sender.login != concat(steps.app-token.outputs.app-slug, '[bot]')";
              uses = "planetscale/ghcommit-action@v0.2.22";
              "with" = {
                commit_message = "chore(deps): sync action updates to nix";
                repo = ghExpr "github.repository";
                branch = ghExpr "github.event.pull_request.head.ref";
              };
              env.GITHUB_TOKEN = ghExpr "steps.app-token.outputs.token";
            }
          ];
        };
      };
    }
  );
}
