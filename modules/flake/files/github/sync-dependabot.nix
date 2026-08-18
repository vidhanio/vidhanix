{ flake-parts-lib, ... }:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    { config, ... }:
    let
      inherit (config.files.lib.github)
        ghExpr
        just
        setupNix
        fetchMetadata
        checkoutHead
        createAppToken
        commitToPrBranch
        ;
    in
    {
      config.files.github.workflows.sync-dependabot = {
        name = "Sync Dependabot";

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

        # a fresh dependabot push supersedes the older run on the same PR
        concurrency = {
          group = ghExpr "github.event.pull_request.number";
          cancel-in-progress = true;
        };

        jobs = {
          # one metadata fetch drives both sync paths; the jobs below dispatch
          # on its ecosystem output instead of matching branch name prefixes.
          metadata = {
            name = "Fetch Dependabot Metadata";
            runs-on = "ubuntu-latest";
            # the author gate keeps the action from failing on other PRs
            "if" = "github.event.pull_request.user.login=='dependabot[bot]'";
            outputs = {
              ecosystem = ghExpr "steps.metadata.outputs.package-ecosystem";
              dependencies = ghExpr "steps.metadata.outputs.updated-dependencies-json";
            };
            steps = [ fetchMetadata ];
          };

          # only dependabot github_actions PRs; the script treats the metadata as data.
          sync-actions = {
            name = "Sync GitHub Actions Updates";
            needs = [ "metadata" ];
            "if" = "needs.metadata.outputs.ecosystem=='github_actions'";
            runs-on = "ubuntu-latest";
            # the head checkout also sets ghcommit's expected branch tip: it
            # must equal the PR branch head or the API commit is refused.
            steps = [
              checkoutHead
              {
                name = "Sync GitHub Actions Updates";
                env.UPDATED_DEPENDENCIES_JSON = ghExpr "needs.metadata.outputs.dependencies";
                run = "python3 .github/scripts/sync-action-updates.py";
              }
              createAppToken
              (commitToPrBranch "chore(ci): sync action updates")
            ];
          };

          # only dependabot nix PRs; `just generate` prunes the new lock and
          # regenerates everything else from it.
          prune-lock = {
            name = "Prune Lock";
            needs = [ "metadata" ];
            "if" = "needs.metadata.outputs.ecosystem=='nix'";
            runs-on = "ubuntu-latest";
            steps = [
              checkoutHead
              setupNix
              createAppToken
              {
                name = "Prune Lock";
                run = "${just} generate";
              }
              (commitToPrBranch "chore(flake): prune lock")
            ];
          };
        };
      };
    }
  );
}
