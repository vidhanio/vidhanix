{ inputs, lib, ... }:
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

  flake.aspects.noctalia = {
    nixos =
      { inputs', ... }:
      {
        programs.noctalia = {
          enable = true;
          package = inputs'.noctalia.packages.default;
          recommendedServices.enable = true;
        };
      };

    homeManager =
      {
        config,
        pkgs,
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
        padding = hyprlandCfg.general.gaps_out;
        radius = hyprlandCfg.decoration.rounding;

        capsuleGroup = id: members: {
          inherit id members;
          fill = "surface_variant";
          opacity = config.stylix.opacity.desktop;
          inherit padding radius;
        };
      in
      {
        imports = [ inputs.noctalia.homeModules.default ];

        stylix.targets.noctalia.image.enable = false;

        programs.noctalia = {
          enable = true;
          systemd.enable = true;

          settings = {
            lockscreen.enabled = false; # handled by hyprlock
            wallpaper.enabled = false; # handled by hyprpaper

            shell = {
              popup_shadows = false;
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

            hooks.theme_mode_changed = pkgs.writeShellScript "noctalia-switch-theme" ''
              mode="''${NOCTALIA_THEME_MODE:-}"
              if [[ "$mode" == dark || "$mode" == light ]]; then
                exec sudo /nix/var/nix/profiles/system/specialisation/$mode/bin/switch-to-configuration test
              fi
            '';

            bar.main = {
              background_opacity = 0;
              capsule_opacity = config.stylix.opacity.desktop;
              capsule_thickness = 1.0;
              border_width = 0;
              shadow = false;

              margin_edge = padding;
              margin_ends = padding;
              padding = 0;
              inherit radius;

              start = [
                "group:datetime"
                "group:system"
              ];
              center = [
                "group:workspaces"
              ];
              end = [
                "group:theme-mode"
                "group:tray"
              ];
              capsule_group = [
                (capsuleGroup "datetime" [
                  "date"
                  "time"
                ])
                (capsuleGroup "system" [
                  "battery"
                  "network"
                  "bluetooth"
                  "volume"
                ])
                (capsuleGroup "workspaces" [ "workspaces" ])
                (capsuleGroup "theme-mode" [ "theme_mode" ])
                (capsuleGroup "tray" [ "tray" ])
              ];
            };
            dock.shadow = false;
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

        systemd.user.services.noctalia.Unit.X-Restart-Triggers = lib.mkForce [ ];

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
