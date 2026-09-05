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

    provides.desktop.homeManager = {
      wayland.windowManager.hyprland.binds."SUPER + H".exec_cmd = "uwsm app -- $TERMINAL herdr";
    };

    provides.apple-silicon.homeManager = {
      wayland.windowManager.hyprland.binds."SUPER + H".exec_cmd =
        "uwsm app -- $TERMINAL herdr --remote vortex";
    };
  };
}
