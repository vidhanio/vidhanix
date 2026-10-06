{
  profiles.pc = {
    homeModule =
      {
        inputs',
        config,
        lib,
        ...
      }:
      let
        presets = config.programs.agents.models.presets;
      in
      {
        programs.pi-coding-agent = {
          enable = true;

          package = inputs'.llm-agents.packages.pi;

          models = lib.mkIf (config.programs.agents.models.override != { }) {
            providers = lib.mapAttrs (_: models: {
              modelOverrides = lib.mapAttrs (_: model: { contextWindow = model.context; }) models;
            }) config.programs.agents.models.override;
          };

          settings = {
            defaultProvider = presets.default.provider;
            defaultModel = presets.default.model;
            defaultThinkingLevel = presets.default.thinking;
          };
        };

        persist.directories = [ ".pi/agent" ];
      };
  };
}
