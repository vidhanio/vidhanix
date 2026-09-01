{
  flake.aspects.omp = {
    homeManager =
      {
        inputs',
        config,
        osConfig,
        ...
      }:
      let
        modelsCfg = config.programs.agents.models;
        searxngCfg = osConfig.services.searx.settings.server;
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
            searxng.endpoint = "http://${searxngCfg.bind_address or "127.0.0.1"}:${toString searxngCfg.port}";

            composer.shape = "pi";
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
