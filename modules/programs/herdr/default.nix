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

        quickAccess = "${config.programs.kitty.package}/bin/kitten quick-access-terminal ${lib.getExe cfg.package}";
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
        binds."SUPER + t".cmd = quickAccess;

        systemd.user.services.herdr-quick-access = {
          Unit = {
            Description = "Herdr quick access terminal";
            After = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
          };

          Install.WantedBy = [ "graphical-session.target" ];

          Service = {
            ExecStart = quickAccess;
            Restart = "always";
            RestartSec = 1;
          };
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
