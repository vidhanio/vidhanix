{
  profiles.pc = {
    homeModule =
      { config, ... }:
      {
        home.file."${config.programs.pi-coding-agent.configDir}/extensions/herdr-agent-state.ts".source =
          "${config.programs.herdr.package}/share/herdr/integrations/pi/herdr-agent-state.ts";
      };
  };
}
