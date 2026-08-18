{
  flake.aspects.herdr.homeManager = { inputs', ... }: {
    programs.herdr = {
      enable = true;

      package = inputs'.llm-agents.packages.herdr;

      settings = {
        onboarding = false;

        ui = {
          tab_bar_position = "bottom";
          show_agent_labels_on_pane_borders = true;
          toast.delivery = "system";
        };

        experimental = {
          kitty_graphics = true;
        };

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

    persist = {
      directories = [ ".herdr/worktrees" ];
      files = [
        {
          file = ".config/herdr/session.json";
          method = "symlink";
        }
      ];
    };
  };
}
