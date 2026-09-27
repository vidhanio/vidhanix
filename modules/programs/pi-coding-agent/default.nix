{
  flake.aspects.pi-coding-agent = {
    homeManager =
      {
        inputs',
        config,
        ...
      }:
      let
        model = config.programs.agents.models.default;
      in
      {
        programs.pi-coding-agent = {
          enable = true;

          package = inputs'.llm-agents.packages.pi;

          settings = {
            defaultProvider = model.provider;
            defaultModel = model.model;
            defaultThinkingLevel = model.thinking;
          };
        };

        persist.directories = [ ".pi/agent" ];
      };
  };
}
