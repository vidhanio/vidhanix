{
  flake.modules.homeManager.default =
    { inputs', ... }:
    {
      programs.omp = {
        enable = true;
        package = inputs'.llm-agents.packages.omp;

        settings = {
          # Immutable config.yml can't persist the wizard's setupVersion, so
          # disable it (it would otherwise run on every launch).
          startup.setupWizard = false;

          providers.webSearchOrder = [ "exa" ];
          exa = {
            enabled = true;
            enableSearch = true;
          };

          startup.checkUpdate = false;
          symbolPreset = "nerd";
          hideThinkingBlock = true;

          modelRoles.default = "opencode-go/deepseek-v4-flash:max";
        };
      };

      persist.directories = [ ".omp" ];
    };
}
