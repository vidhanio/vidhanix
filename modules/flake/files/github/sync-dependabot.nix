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
          # Saving the store cache requires `actions: write`.
          contents = "write";
          pull-requests = "write";
          actions = "write";
        };

        concurrency = {
          group = ghExpr "github.event.pull_request.number";
          cancel-in-progress = true;
        };

        jobs = {
          metadata = {
            name = "Fetch Dependabot Metadata";
            runs-on = "ubuntu-latest";
            "if" = "github.event.pull_request.user.login=='dependabot[bot]'";
            outputs = {
              ecosystem = ghExpr "steps.metadata.outputs.package-ecosystem";
              dependencies = ghExpr "steps.metadata.outputs.updated-dependencies-json";
            };
            steps = [ fetchMetadata ];
          };

          sync-actions = {
            name = "Sync GitHub Actions Updates";
            needs = [ "metadata" ];
            "if" = "needs.metadata.outputs.ecosystem=='github_actions'";
            runs-on = "ubuntu-latest";
            # The head checkout also sets the expected branch tip for `ghcommit`: it
            # must equal the PR branch head or the API commit is refused.
            steps = [
              checkoutHead
              {
                name = "Sync GitHub Actions Updates";
                env.UPDATED_DEPENDENCIES_JSON = ghExpr "needs.metadata.outputs.dependencies";
                run = "python3 .github/scripts/sync-action-updates.py";
              }
              createAppToken
              (commitToPrBranch "ci: sync action updates")
            ];
          };

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
                run = ''
                  ${just} fmt
                  nix flake lock
                '';
              }
              (commitToPrBranch "flake: prune lock")
            ];
          };
        };
      };
    }
  );
}
