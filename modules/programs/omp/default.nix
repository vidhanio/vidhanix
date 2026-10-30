{
  profiles.pc = {
    module =
      { config, lib, ... }:
      {
        systemd.services = lib.mapAttrs' (
          name: user:
          lib.nameValuePair "home-manager-${name}" {
            unitConfig.RequiresMountsFor = [ "${user.home.homeDirectory}/.omp" ];
          }
        ) config.home-manager.users;
      };

    homeModule =
      {
        inputs',
        config,
        lib,
        osConfig,
        ...
      }:
      let
        presets = config.agents.models.presets;
        searxngCfg = osConfig.services.searx.settings.server;
      in
      {
        programs.omp = {
          enable = true;
          enableMcpIntegration = true;
          package = inputs'.llm-agents.packages.omp;

          models = lib.mkIf (config.agents.models.override != { }) {
            providers = lib.mapAttrs (_: models: {
              modelOverrides = lib.mapAttrs (_: model: { contextWindow = model.context; }) models;
            }) config.agents.models.override;
          };

          themes.stylix.symbols.overrides = {
            "boxRound.topLeft" = "┌";
            "boxRound.topRight" = "┐";
            "boxRound.bottomLeft" = "└";
            "boxRound.bottomRight" = "┘";
          };

          settings = {
            startup = {
              setupWizard = false;
              checkUpdate = false;
            };

            task = {
              isolation.enabled = true;
              agentModelOverrides.reviewer = "${presets.reviewer.provider}/${presets.reviewer.model}:${presets.reviewer.thinking}";
            };
            composer.shape = "pi";
            symbolPreset = "nerd";

            completion.notify = "off";
            ask.notify = "off";

            modelRoles = {
              default = "${presets.default.provider}/${presets.default.model}:${presets.default.thinking}";
              smol = "${presets.small.provider}/${presets.small.model}:${presets.small.thinking}";
              advisor = "${presets.reviewer.provider}/${presets.reviewer.model}:${presets.reviewer.thinking}";
              web = "web/searxng";
            };

            searxng.endpoint = "http://${searxngCfg.bindAddress}:${toString searxngCfg.port}";
          };
        };

        persist.directories = [ ".omp" ];
      };
  };
}
