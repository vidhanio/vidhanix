{ lib, ... }: {
  profiles.pc = {
    homeModule =
      {
        pkgs,
        inputs',
        ...
      }:
      let
        herdr = inputs'.llm-agents.packages.herdr;
        launch = "ghostty --class=dev.herdr -e herdr";
        desktopItem = pkgs.makeDesktopItem {
          name = "herdr";
          desktopName = "Herdr";
          comment = herdr.meta.description;
          exec = launch;
          icon = "herdr";
          terminal = false;
          categories = [ "Development" ];
          startupWMClass = "dev.herdr";
        };
        icon = pkgs.runCommandLocal "herdr-icon" { } ''
          install -Dm644 ${herdr.src}/assets/logo.svg \
            $out/share/icons/hicolor/scalable/apps/herdr.svg
        '';
        package = pkgs.symlinkJoin {
          inherit (herdr) meta;
          inherit (herdr) name;
          passthru.src = herdr.src;
          paths = [
            herdr
            desktopItem
            icon
          ];
        };

      in
      {
        programs.herdr = {
          enable = true;

          inherit package;

          settings = {
            onboarding = false;

            ui = {
              toast.delivery = "system";
              pane_borders = "always";
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

        programs.agents.skills.herdr = "${herdr.src}/skills/herdr";

        desktop = {
          binds."SUPER + t".app = {
            cmd = launch;
            focusAppId = "dev.herdr";
          };
          binds."SUPER + SHIFT + t".app = launch;
          workspaces.work.apps = [ "dev.herdr" ];
        };

        xdg.autostart.entries = [ "${package}/share/applications/herdr.desktop" ];

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
