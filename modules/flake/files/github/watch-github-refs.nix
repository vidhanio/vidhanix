{ flake-parts-lib, ... }:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption {
    config.files.github.workflows.watch-github-refs = {
      name = "Watch GitHub References";

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
        name = "Watch GitHub Reference Issues";
        runs-on = "ubuntu-latest";
        steps = [
          {
            name = "Checkout";
            uses = "actions/checkout@v7";
          }
          {
            name = "Scan and Notify";
            run = "bash .github/scripts/watch-github-refs.sh";
          }
        ];
      };
    };
  };
}
