{ flake-parts-lib, ... }:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    { config, ... }:
    let
      inherit (config.workflowCommon)
        ghExpr
        just
        setupNix
        createAppToken
        ;
    in
    {
      config.files.workflows.prune-lock = {
        name = "prune lock";

        on.pull_request_target = {
          branches = [ "main" ];
          types = [
            "opened"
            "synchronize"
            "reopened"
          ];
        };

        permissions = {
          # the store cache save needs actions: write
          contents = "write";
          pull-requests = "write";
          actions = "write";
        };

        jobs.prune = {
          name = "prune lock";
          runs-on = "ubuntu-latest";
          # only dependabot nix PRs; `just generate` prunes the new lock and
          # regenerates everything else from it.
          "if" =
            "github.event.pull_request.user.login=='dependabot[bot]' && startsWith(github.event.pull_request.head.ref,'dependabot/nix/')";
          steps = [
            {
              name = "checkout";
              uses = "actions/checkout@v5";
              "with" = {
                fetch-depth = 0;
                ref = ghExpr "github.event.pull_request.head.sha";
              };
            }
            setupNix
            createAppToken
            {
              name = "prune lock";
              run = "${just} generate";
            }
            {
              name = "commit";
              uses = "planetscale/ghcommit-action@v0.2.22";
              "with" = {
                commit_message = "chore(flake): prune lock";
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
