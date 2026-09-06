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
      {
        programs.noctalia = {
          enable = true;
          systemd.enable = true;
          customPalettes.stylix.dark.mSurface = lib.mkForce config.lib.stylix.colors.withHashtag.base00;

          settings = {
            lockscreen.enabled = false; # handled by hyprlock
            screenshot = {
              save_to_file = false;
              copy_to_clipboard = true;
            };

            shell = {
              corner_radius_scale = config.stylix.cornerRadius;
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
              padding = config.stylix.padding;
              widget_spacing = 10;
              radius = config.stylix.cornerRadius;
              capsule_radius = config.stylix.cornerRadius;

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
