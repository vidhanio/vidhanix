{
  flake.modules.homeManager.default =
    { inputs', config, ... }:
    {
      home.shellAliases.h = "herdr";

      programs.herdr = {
        enable = true;
        package = inputs'.llm-agents.packages.herdr;

        settings = {
          onboarding = false;

          ui.tab_bar_position = "bottom";

          experimental.kitty_graphics = true;

          experimental.pane_history = true;

          keys.command = [
            {
              key = "prefix+alt+g";
              type = "popup";
              command = "lazygit";
              width = "80%";
              height = "80%";
              description = "lazygit";
            }
          ];
        };
      };

      programs.claude-code = {
        skills.herdr = ./skills/herdr.md;

        hooks."herdr-agent-state.sh" = builtins.readFile ./hooks/herdr-agent-state.sh;

        settings.hooks.SessionStart = [
          {
            matcher = "*";
            hooks = [
              {
                type = "command";
                command = "bash '${config.programs.claude-code.configDir}/hooks/herdr-agent-state.sh' session";
                timeout = 10;
              }
            ];
          }
        ];
      };

      persist.files =
        map
          (file: {
            inherit file;
            method = "symlink";
          })
          [
            ".config/herdr/session.json"
            ".config/herdr/session-history.json"
          ];
    };
}
