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
        binds."SUPER + t".cmd =
          "${config.programs.kitty.package}/bin/kitten quick-access-terminal ${lib.getExe cfg.package}";

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
