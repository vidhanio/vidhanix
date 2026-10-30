{
  profiles.pc = {
    homeModule =
      { config, ... }:
      {
        home.file.".omp/agent/extensions/herdr-omp-agent-state.ts".source =
          "${config.programs.herdr.package}/share/herdr/integrations/omp/herdr-agent-state.ts";
      };
  };
}
