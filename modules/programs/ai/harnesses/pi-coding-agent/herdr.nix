{
  flake.modules.homeManager.default =
    { config, ... }:
    {
      home.file."${config.programs.pi-coding-agent.configDir}/extensions/herdr-agent-state.ts".source =
        "${config.programs.herdr.package.src}/src/integration/assets/pi/herdr-agent-state.ts";
    };
}
