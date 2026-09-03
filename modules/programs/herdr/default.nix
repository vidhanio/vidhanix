{
  flake.aspects.herdr = {
    homeManager =
      {
        config,
        inputs',
        ...
      }:
      let
        cfg = config.programs.herdr;
      in
      {
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

        programs.agents.skills.herdr = "${cfg.package.src}/skills/herdr";

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

    _.desktop.homeManager = {
      wayland.windowManager.hyprland.binds."SUPER + H".exec_cmd = "$TERMINAL herdr";
    };

    _.apple-silicon.homeManager = {
      wayland.windowManager.hyprland.binds."SUPER + H".exec_cmd = "$TERMINAL herdr --remote vortex";
    };
  };
}
