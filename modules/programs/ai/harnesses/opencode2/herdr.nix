{
  flake.modules.homeManager.default =
    { config, ... }:
    {
      xdg.configFile."opencode/plugins/herdr-agent-state.js".source =
        "${config.programs.herdr.package.src}/src/integration/assets/opencode/herdr-agent-state.js";
    };
}
