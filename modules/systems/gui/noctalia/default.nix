{ inputs, ... }:
{
  flake-file.inputs.noctalia.url = "github:noctalia-dev/noctalia/cachix";

  # https://docs.noctalia.dev/v5/getting-started/nixos/?section=binary-cache#binary-cache
  flake-file.nixConfig = {
    extra-substituters = [ "https://noctalia.cachix.org" ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  flake.modules = {
    nixos.default = {
      imports = [ inputs.noctalia.nixosModules.default ];

      programs.noctalia = {
        enable = true;
        recommendedServices.enable = true;
      };
    };

    homeManager.default =
      let
        msg = command: { exec_cmd = "noctalia msg ${command}"; };
        repeating =
          bind:
          bind
          // {
            _flags = {
              repeating = true;
              locked = true;
            };
          };
        locked = bind: bind // { _flags.locked = true; };
      in
      {
        imports = [ inputs.noctalia.homeModules.default ];

        programs.noctalia = {
          enable = true;
          systemd.enable = true;

          settings = {
            wallpaper.enabled = false; # handled by hyprpaper
            weather.enabled = false;

            shell = {
              launch_apps_custom_command = "uwsm app -- $CMD";
              popup_shadows = false;
              panel.shadow = false;
              setup_wizard_enabled = false;
            };

            dock.shadow = false;

            bar.main = {
              background_opacity = 1.0;
              border_width = 2;
              shadow = false;

              # match hyprland's gaps_out
              margin_edge = 8;
              margin_ends = 8;

              # match hyprland rounding
              radius = 8;
              padding = 8;

              start = [
                "clock"
                "spacer"
                "battery"
                "network"
                "bluetooth"
                "volume"
              ];
              center = [
                "workspaces"
              ];
              end = [
                "tray"
              ];
            };

            widget.clock.format = "{:%a %d %b  %H:%M}";
            widget.network.show_label = false; # hide ssid
          };
        };

        persist.directories = [ ".local/state/noctalia" ];
        systemd.user.tmpfiles.rules = [
          "r %h/.local/state/noctalia/settings.toml" # get rid of imperative settings
        ];

        hyprland.binds = {
          # core binds
          "SUPER + e" = msg "panel-toggle launcher";

          # volume / mic
          "XF86AudioRaiseVolume" = repeating (msg "volume-up");
          "XF86AudioLowerVolume" = repeating (msg "volume-down");
          "XF86AudioMute" = repeating (msg "volume-mute");
          "XF86AudioMicMute" = repeating (msg "mic-mute");

          # brightness
          "XF86MonBrightnessUp" = repeating (msg "brightness-up");
          "XF86MonBrightnessDown" = repeating (msg "brightness-down");
          "SHIFT + XF86MonBrightnessUp" = repeating (msg "keyboard-backlight-up");
          "SHIFT + XF86MonBrightnessDown" = repeating (msg "keyboard-backlight-down");

          # media playback
          "XF86AudioPlay" = locked (msg "media toggle");
          "XF86AudioPause" = locked (msg "media toggle");
          "XF86AudioNext" = locked (msg "media next");
          "XF86AudioPrev" = locked (msg "media previous");
        };

        wayland.windowManager.hyprland.settings = {
          window_rule = [
            {
              match.class = "dev.noctalia.Noctalia";

              float = true;
              size = [
                1080
                920
              ];
            }
          ];

          layer_rule = [
            {
              name = "noctalia";

              match.namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$";
            }
          ];
        };
      };
  };
}
