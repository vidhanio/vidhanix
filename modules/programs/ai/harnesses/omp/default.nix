{
  flake.modules.homeManager.default =
    { inputs', ... }:
    {
      programs.omp = {
        enable = true;
        enableMcpIntegration = true;
        package = inputs'.llm-agents.packages.omp;

        settings = {
          startup = {
            setupWizard = false;
          };

          providers.webSearchOrder = [ "exa" ];
          exa = {
            enabled = true;
            enableSearch = true;
          };

          symbolPreset = "nerd";

          modelRoles.default = "opencode-go/deepseek-v4-flash:max";
        };

        # TODO: https://github.com/can1357/oh-my-pi/pull/8064
        models.providers.opencode-go.modelOverrides.deepseek-v4-flash = {
          thinking = {
            mode = "effort";
            efforts = [
              "low"
              "high"
              "max"
            ];
          };
        };
      };

      persist.directories = [ ".omp" ];
    };
}
