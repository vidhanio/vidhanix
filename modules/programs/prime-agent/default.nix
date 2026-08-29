{
  flake.aspects.prime-agent = {
    homeManager =
      {
        inputs',
        config,
        ...
      }:
      let
        model = config.programs.agents.models.large;
        pkg = inputs'.llm-agents.packages.prime-agent;
      in
      {
        programs.prime-agent = {
          enable = true;
          enableMcpIntegration = true;

          package = pkg;

          settings = {
            defaultProvider = model.provider;
            defaultModel = model.model;
            defaultThinkingLevel = model.thinking;
            telemetry.enabled = false;
          };
        };

        persist.directories = [ ".prime/agent" ];
      };
  };
}
