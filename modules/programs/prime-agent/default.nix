{
  flake.aspects.prime-agent = {
    homeManager =
      { inputs', ... }:
      let
        pkg = inputs'.llm-agents.packages.prime-agent;
      in
      {
        programs.prime-agent = {
          enable = true;
          enableMcpIntegration = true;

          package = pkg;

          settings.telemetry.enabled = false;
        };

        persist.directories = [ ".prime/agent" ];
      };
  };
}
