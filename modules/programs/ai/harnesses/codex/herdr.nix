{
  flake.modules.homeManager.default =
    { config, ... }:
    {
      home.file.".codex/herdr-agent-state.sh" = {
        source = "${config.programs.herdr.package.src}/src/integration/assets/codex/herdr-agent-state.sh";
        executable = true;
      };

      programs.codex = {
        hooks.SessionStart = [
          {
            hooks = [
              {
                type = "command";
                command = "bash '${config.home.homeDirectory}/.codex/herdr-agent-state.sh' session";
                timeout = 10;
              }
            ];
          }
        ];

        settings.features.hooks = true;
      };
    };
}
