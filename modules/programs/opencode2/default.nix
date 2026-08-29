{
  flake.aspects.opencode2 = {
    homeManager =
      {
        inputs',
        config,
        ...
      }:
      let
        model = config.programs.agents.models.large;
      in
      {
        programs.opencode2 = {
          enable = true;
          enableMcpIntegration = true;

          package = inputs'.llm-agents.packages.opencode2;

          settings.model = "${model.provider}/${model.model}";
        };

        persist.directories = [
          ".config/opencode"
          ".local/share/opencode"
          ".local/state/opencode"
        ];
      };
  };
}
