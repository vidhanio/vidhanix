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

        binds."SUPER + SHIFT + t".app = lib.mkDefault "$TERMINAL herdr";

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
