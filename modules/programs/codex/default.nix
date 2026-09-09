{
  flake.aspects.codex = {
    homeManager =
      { inputs', ... }:
      {
        programs.codex = {
          enable = true;
          enableMcpIntegration = true;
          package = inputs'.llm-agents.packages.codex;
        };

        persist.directories = [ ".codex" ];
      };
  };
}
