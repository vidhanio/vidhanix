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
        };

        persist.directories = [ ".prime/agent" ];
      };
  };
}
