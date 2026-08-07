{ inputs, ... }:
{
  flake-file = {
    inputs = {
      noctalia.url = "github:noctalia-dev/noctalia/cachix";
    };
    nixConfig = {
      extra-substituters = [ "https://noctalia.cachix.org" ];
      extra-trusted-public-keys = [
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      ];
    };
    prune-lock.ignore = [ "noctalia" ];
  };

  flake.modules = {
    nixos.default =
      { inputs', ... }:
      {
        programs.noctalia = {
          enable = true;
          package = inputs'.noctalia.packages.default;
          recommendedServices.enable = true;
        };
      };

    homeManager.default =
      { config, ... }:
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
            lockscreen.enabled = false; # handled by hyprlock
            wallpaper.enabled = false; # handled by hyprpaper

            shell = {
              launch_apps_custom_command = "uwsm app -- $CMD";
              setup_wizard_enabled = false;
              external_ip_enabled = true;
            };

            location.auto_locate = true;

            bar.main = {
              background_opacity = config.stylix.opacity.desktop;
              border_width = 2;

              # match hyprland's gaps_out
              margin_edge = 8;
              margin_ends = 8;

              # match hyprland rounding
              radius = 8;
              padding = 8;

              start = [
                "date"
                "time"
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
            widget = {
              date = {
                type = "clock";
                format = "{:%B %-d, %Y}";
              };
              time = {
                type = "clock";
                format = "{:%H:%M:%S}";
              };
              network.show_label = false;
              workspaces.style = "minimal";
            };
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

              no_anim = true;
              ignore_alpha = 0.5;
              blur = true;
              blur_popups = true;
            }
          ];
        };
      };
  };
}
