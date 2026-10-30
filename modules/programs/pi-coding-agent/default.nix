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
        presets = config.agents.models.presets;
      in
      {
        programs.pi-coding-agent = {
          enable = true;

          package = inputs'.llm-agents.packages.pi;

          models = lib.mkIf (config.agents.models.override != { }) {
            providers = lib.mapAttrs (_: models: {
              modelOverrides = lib.mapAttrs (_: model: { contextWindow = model.context; }) models;
            }) config.agents.models.override;
          };

          settings = {
            defaultProvider = presets.default.provider;
            defaultModel = presets.default.model;
            defaultThinkingLevel = presets.default.thinking;
            enabledModels = map (preset: "${preset.provider}/${preset.model}:${preset.thinking}") [
              presets.default
              presets.reviewer
              presets.small
            ];
          };
        };

        persist.directories = [ ".pi/agent" ];
      };
  };
}
