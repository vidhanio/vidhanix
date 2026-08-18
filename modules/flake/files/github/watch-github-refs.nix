{ flake-parts-lib, ... }:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption {
    config.files.github.workflows.watch-github-refs = {
      name = "Watch GitHub references";

      on = {
        schedule = [
          { cron = "0 9 * * *"; }
        ];
        workflow_dispatch = { };
      };

      permissions = {
        issues = "write";
        contents = "read";
      };

      jobs.watch = {
        name = "Watch GitHub reference issues";
        runs-on = "ubuntu-latest";
        steps = [
          {
            name = "Checkout";
            uses = "actions/checkout@v5";
          }
          {
            name = "Scan and notify";
            run = "bash .github/scripts/watch-github-refs.sh";
          }
        ];
      };
    };
  };
}
