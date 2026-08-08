{
  flake.modules.homeManager.default =
    { inputs', ... }:
    {
      programs.omp = {
        enable = true;
        package = inputs'.llm-agents.packages.omp;

        settings = {
          startup.checkUpdate = false;
          symbolPreset = "nerd";

          modelRoles.default = "opencode-go/deepseek-v4-flash:max";
        };
      };

      persist.directories = [ ".omp" ];
    };
}
