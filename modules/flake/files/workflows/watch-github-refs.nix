{ flake-parts-lib, ... }:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (_: {
    config.files.workflows.watch-github-refs = {
      name = "watch github refs";

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
        name = "watch github refs issues";
        runs-on = "ubuntu-latest";
        steps = [
          {
            name = "checkout";
            uses = "actions/checkout@v7";
          }
          {
            name = "scan and notify";
            run = "bash .github/scripts/watch-github-refs.sh";
          }
        ];
      };
    };
  });
}
