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
      { lib, ... }:
      let
        bind = keys: dispatcher: {
          _args = [
            keys
            (lib.generators.mkLuaInline dispatcher)
          ];
        };
        repeatBind = keys: dispatcher: {
          _args = [
            keys
            (lib.generators.mkLuaInline dispatcher)
            {
              repeating = true;
              locked = true;
            }
          ];
        };
        lockedBind = keys: dispatcher: {
          _args = [
            keys
            (lib.generators.mkLuaInline dispatcher)
            { locked = true; }
          ];
        };
        msg = command: ''hl.dsp.exec_cmd("noctalia msg ${command}")'';
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
                "volume"
                "network"
                "bluetooth"
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

        # https://docs.noctalia.dev/v5/compositor-settings/hyprland/
        wayland.windowManager.hyprland.settings = {
          bind = [
            # core binds
            (bind "SUPER + e" (msg "panel-toggle launcher"))
            (bind "ALT + Tab" (msg "window-switcher"))

            # volume / mic
            (repeatBind "XF86AudioRaiseVolume" (msg "volume-up"))
            (repeatBind "XF86AudioLowerVolume" (msg "volume-down"))
            (repeatBind "XF86AudioMute" (msg "volume-mute"))
            (repeatBind "XF86AudioMicMute" (msg "mic-mute"))

            # brightness
            (repeatBind "XF86MonBrightnessUp" (msg "brightness-up"))
            (repeatBind "XF86MonBrightnessDown" (msg "brightness-down"))

            # media playback
            (lockedBind "XF86AudioPlay" (msg "media toggle"))
            (lockedBind "XF86AudioPause" (msg "media toggle"))
            (lockedBind "XF86AudioNext" (msg "media next"))
            (lockedBind "XF86AudioPrev" (msg "media previous"))
          ];

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
            }
          ];
        };
      };
  };
}
