{
  flake.aspects.noctalia = {
    nixos = {
      programs.noctalia = {
        enable = true;
        recommendedServices.enable = true;
      };
    };

    homeManager =
      {
        config,
        lib,
        ...
      }:
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

        hyprlandCfg = config.wayland.windowManager.hyprland.settings.config;
      in
      {
        stylix.targets.noctalia.image.enable = false;

        programs.noctalia = {
          enable = true;
          systemd.enable = true;
          customPalettes.stylix.dark.mSurface = lib.mkForce config.lib.stylix.colors.withHashtag.base00;

          settings = {
            lockscreen.enabled = false; # handled by hyprlock
            wallpaper.enabled = false; # handled by hyprpaper

            shell = {
              corner_radius_scale = hyprlandCfg.decoration.rounding;
              panel = {
                control_center_placement = "floating";
                shadow = false;
                transparency_mode =
                  if config.stylix.opacity.popups == 1.0 then
                    "solid"
                  else if config.stylix.opacity.popups >= 0.6 then
                    "soft"
                  else
                    "glass";
              };

              launch_apps_custom_command = "uwsm app -- $CMD";
              setup_wizard_enabled = false;
              external_ip_enabled = true;
            };

            location.auto_locate = true;

            bar.main = {
              position = "top";
              background_opacity = 1.0;
              border_width = hyprlandCfg.general.border_size;
              shadow = false;
              capsule = false;

              margin_edge = 0;
              margin_ends = 0;
              padding = hyprlandCfg.general.gaps_out;
              radius = 0;

              start = [
                "tray"
                "workspaces"
              ];
              center = [
                "datetime"
              ];
              end = [
                "volume"
                "network"
                "battery"
              ];
            };
            dock.shadow = false;
            widget = {
              datetime = {
                type = "clock";
                format = "{:%B %-d, %Y} {:%H:%M:%S}";
              };
              workspaces.style = "minimal";
            };
          };
        };

        persist.directories = [ ".local/state/noctalia" ];
        systemd.user.tmpfiles.rules = [
          "r %h/.local/state/noctalia/settings.toml" # get rid of imperative settings
        ];

        wayland.windowManager.hyprland.binds = {
          "SUPER + e" = msg "panel-toggle launcher";

          "XF86AudioRaiseVolume" = repeating (msg "volume-up");
          "XF86AudioLowerVolume" = repeating (msg "volume-down");
          "XF86AudioMute" = repeating (msg "volume-mute");
          "XF86AudioMicMute" = repeating (msg "mic-mute");

          "XF86MonBrightnessUp" = repeating (msg "brightness-up");
          "XF86MonBrightnessDown" = repeating (msg "brightness-down");
          "SHIFT + XF86MonBrightnessUp" = repeating (msg "keyboard-backlight-up");
          "SHIFT + XF86MonBrightnessDown" = repeating (msg "keyboard-backlight-down");

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
              ignore_alpha = 0;
              blur = true;
              blur_popups = true;
            }
          ];
        };
      };
  };
}
