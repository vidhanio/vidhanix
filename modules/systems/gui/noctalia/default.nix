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
        msg = command: {
          exec = "noctalia msg ${command}";
        };
        hyprlandMsg = flags: command: {
          hyprland.dsp = {
            exec_cmd = "noctalia msg ${command}";
            _flags = flags;
          };
        };
        repeating = hyprlandMsg {
          repeating = true;
          locked = true;
        };
        locked = hyprlandMsg { locked = true; };

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
            screenshot = {
              save_to_file = false;
              copy_to_clipboard = true;
            };

            shell = {
              corner_radius_scale = hyprlandCfg.decoration.rounding;
              popup_shadows = false;
              panel = {
                open_near_click_control_center = true;
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
              thickness = 40;
              background_opacity = 1.0;
              shadow = false;
              capsule = false;

              margin_edge = 0;
              margin_ends = 0;
              padding = hyprlandCfg.general.gaps_out;
              widget_spacing = 10;
              radius = hyprlandCfg.decoration.rounding;
              capsule_radius = hyprlandCfg.decoration.rounding;

              start = [
                "tray"
                "workspaces"
              ];
              center = [
                "clock"
                "notifications"
              ];
              end = [
                "volume"
                "network"
                "bluetooth"
                "battery"
              ];
            };
            control_center.sidebar_section = "none";
            widget = {
              tray.drawer = true;

              clock = {
                anchor = true;
                format = "{:%B %-d, %Y} {:%H:%M}";
              };

              volume.show_label = false;
              network.show_label = false;
              bluetooth.show_label = false;
              battery.show_label = false;
            };
            dock.shadow = false;
          };
        };

        persist.directories = [ ".local/state/noctalia" ];
        systemd.user.tmpfiles.rules = [
          "r %h/.local/state/noctalia/settings.toml" # get rid of imperative settings
        ];

        binds = {
          "SUPER + e" = msg "panel-toggle launcher";

          "XF86AudioRaiseVolume" = repeating "volume-up";
          "XF86AudioLowerVolume" = repeating "volume-down";
          "XF86AudioMute" = repeating "volume-mute";
          "XF86AudioMicMute" = repeating "mic-mute";

          "XF86MonBrightnessUp" = repeating "brightness-up";
          "XF86MonBrightnessDown" = repeating "brightness-down";
          "SHIFT + XF86MonBrightnessUp" = repeating "keyboard-backlight-up";
          "SHIFT + XF86MonBrightnessDown" = repeating "keyboard-backlight-down";

          "XF86AudioPlay" = locked "media toggle";
          "XF86AudioPause" = locked "media toggle";
          "XF86AudioNext" = locked "media next";
          "XF86AudioPrev" = locked "media previous";
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
