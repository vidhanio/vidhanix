{ lib, ... }: {
  flake.aspects.herdr = {
    homeManager =
      {
        config,
        pkgs,
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
              toast.delivery = "system";
            };

            keys.command = [
              {
                key = "prefix+alt+g";
                type = "popup";
                command = lib.getExe pkgs.lazygit;
                description = "run lazygit";
                width = "90%";
                height = "90%";
              }
            ];
          };
        };

        programs.agents.skills.herdr = "${cfg.package.src}/skills/herdr";
        desktop.binds."SUPER + t" = {
          niri.cmd = "ghostty --class=dev.herdr -e herdr";
          hyprland.dsp."workspace.toggle_special"._args = [ "herdr" ];
        };
        desktop.workspaces.herdr = {
          special = true;
          onCreatedEmpty = "ghostty --class=dev.herdr -e herdr";
        };

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
