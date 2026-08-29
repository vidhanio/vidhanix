{
  flake.aspects.omp = {
    homeManager =
      {
        inputs',
        config,
        ...
      }:
      let
        modelsCfg = config.programs.agents.models;
      in
      {
        programs.omp = {
          enable = true;
          enableMcpIntegration = true;
          package = inputs'.llm-agents.packages.omp;

          settings = {
            startup = {
              setupWizard = false;
            };

            providers.webSearchOrder = [ "searxng" ];
            searxng.endpoint = "http://vortex:8080";

            symbolPreset = "nerd";
            modelRoles = {
              default = "${modelsCfg.large.provider}/${modelsCfg.large.model}:${modelsCfg.large.thinking}";
              smol = "${modelsCfg.small.provider}/${modelsCfg.small.model}:${modelsCfg.small.thinking}";
            };
          };
        };

        persist.directories = [ ".omp" ];
      };
  };
}
