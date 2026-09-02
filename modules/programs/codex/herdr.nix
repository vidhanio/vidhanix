{
  flake.aspects.codex = {
    homeManager =
      {
        config,
        lib,
        ...
      }:
      {
        programs.codex = {
          settings.features.hooks = true;

          hooks.SessionStart = [
            {
              hooks = [
                {
                  type = "command";
                  command = "bash ${lib.escapeShellArg "${config.home.homeDirectory}/.codex/herdr-agent-state.sh"} session";
                  timeout = 10;
                }
              ];
            }
          ];
        };

        home.file.".codex/herdr-agent-state.sh" = {
          executable = true;
          source = "${config.programs.herdr.package.src}/src/integration/assets/codex/herdr-agent-state.sh";
        };
      };
  };
}
