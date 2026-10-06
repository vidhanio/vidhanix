{
  profiles.pc = {
    homeModule =
      {
        inputs',
        config,
        lib,
        osConfig,
        ...
      }:
      let
        presets = config.programs.agents.models.presets;
        searxngCfg = osConfig.services.searx.settings.server;
      in
      {
        programs.omp = {
          enable = true;
          enableMcpIntegration = true;
          package = inputs'.llm-agents.packages.omp;

          models = lib.mkIf (config.programs.agents.models.override != { }) {
            providers = lib.mapAttrs (_: models: {
              modelOverrides = lib.mapAttrs (_: model: { contextWindow = model.context; }) models;
            }) config.programs.agents.models.override;
          };

          settings = {
            startup = {
              setupWizard = false;
              checkUpdate = false;
            };

            task.isolation.enabled = true;
            composer.shape = "pi";
            symbolPreset = "nerd";

            completion.notify = "off";
            ask.notify = "off";

            modelRoles = {
              default = "${presets.default.provider}/${presets.default.model}:${presets.default.thinking}";
              smol = "${presets.small.provider}/${presets.small.model}:${presets.small.thinking}";
              slow = "${presets.large.provider}/${presets.large.model}:${presets.large.thinking}";
              web = "web/searxng";
            };

            searxng.endpoint = "http://${searxngCfg.bindAddress}:${toString searxngCfg.port}";
          };
        };

        persist.directories = [ ".omp" ];
      };
  };
}
