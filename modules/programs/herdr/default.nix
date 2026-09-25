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

        toggle = pkgs.writeShellApplication {
          name = "herdr-toggle";
          runtimeInputs = [
            pkgs.jq
            pkgs.niri
            config.programs.kitty.package
          ];
          text = ''
            windows=$(niri msg --json windows | jq -c '[.[] | select(.app_id == "herdr")]')

            if [[ $(jq 'length' <<<"$windows") == 0 ]]; then
              niri msg action spawn-sh -- "kitty --app-id=herdr herdr"
              exit 0
            fi

            focused=$(jq -r '[.[] | select(.is_focused) | .id] | first // empty' <<<"$windows")

            if [[ -n $focused ]]; then
              niri msg action close-window --id "$focused"
              exit 0
            fi

            window=$(jq -r '.[0].id' <<<"$windows")
            output=$(niri msg --json focused-output | jq -r '.name')
            workspace=$(niri msg --json workspaces | jq -r '[.[] | select(.is_focused) | .idx] | first')

            niri msg action move-window-to-monitor --id "$window" "$output"
            niri msg action move-window-to-workspace --window-id "$window" "$workspace"
            niri msg action move-window-to-floating --id "$window"
            niri msg action set-window-width --id "$window" 90%
            niri msg action set-window-height --id "$window" 90%
            niri msg action focus-window --id "$window"
          '';
        };
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
        binds."SUPER + t".niri.cmd = lib.getExe toggle;

        wayland.windowManager.niri.settings._children = [
          {
            window-rule = {
              match._props.app-id = "^herdr$";
              open-floating = true;
              default-column-width.proportion = 0.9;
              default-window-height.proportion = 0.9;
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
