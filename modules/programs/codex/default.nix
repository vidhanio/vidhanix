{
  flake.aspects.codex = {
    homeManager =
      { inputs', ... }:
      {
        programs.codex = {
          enable = true;
          enableMcpIntegration = true;
          package = inputs'.llm-agents.packages.codex;
          settings.projects."/home/vidhanio/Projects".trust_level = "trusted";
        };

        persist.directories = [ ".codex" ];
      };
  };
}
