{ lib, ... }: {
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
              toast.delivery = "system";
            };

            experimental = {
              kitty_graphics = true;
            };
          };
        };

        programs.agents.skills.herdr = "${cfg.package.src}/skills/herdr";

        wayland.windowManager.hyprland.binds."SUPER + H".exec_cmd =
          lib.mkDefault "uwsm app -- $TERMINAL herdr --remote vortex";

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

    provides.vortex.homeManager = {
      wayland.windowManager.hyprland.binds."SUPER + H".exec_cmd = "uwsm app -- $TERMINAL herdr";
    };
  };
}
