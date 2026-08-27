{
  flake.aspects.opencode2 = {
    homeManager =
      { inputs', ... }:
      {
        programs.opencode2 = {
          enable = true;
          enableMcpIntegration = true;

          package = inputs'.llm-agents.packages.opencode2;
        };

        persist.directories = [
          ".config/opencode"
          ".local/share/opencode"
          ".local/state/opencode"
        ];
      };
  };
}
