{
  flake.modules.homeManager.default =
    { inputs', ... }:
    {
      home.shellAliases.h = "herdr";

      programs.herdr = {
        enable = true;
        package = inputs'.llm-agents.packages.herdr;

        settings = {
          onboarding = false;

          ui.tab_bar_position = "bottom";
          ui.show_agent_labels_on_pane_borders = true;
          ui.toast.delivery = "system";

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

      programs.agents.skills.skills.herdr = ./SKILL.md;

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
