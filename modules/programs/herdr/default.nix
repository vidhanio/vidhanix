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
          };
        };

        programs.agents.skills.herdr = "${cfg.package.src}/skills/herdr";
        binds."SUPER + t".niri.cmd = ''
          ${lib.getExe' inputs'.niri-scratchpad.packages.default "niri-scratchpad"} target --spawn "$TERMINAL --app-id=herdr herdr" appid herdr
        '';

        wayland.windowManager.niri.settings._children = [
          {
            window-rule = {
              match._props.app-id = "^herdr$";
              open-floating = true;
              default-column-width.proportion = 1.0;
              default-window-height.proportion = 1.0;
            };
          }
        ];

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
  };
}
