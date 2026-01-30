{ lib, ... }:
{
  flake.modules = {
    homeManager.default = {
      wayland.windowManager.hyprland.settings = lib.mkMerge [
        {
          windowrule = [
            {
              name = "suppress-maximize-events";

              match.class = ".*";

              suppress_event = "maximize";
            }
            {
              name = "fix-xwayland-drags";

              match = {
                class = "^$";
                title = "^$";
                xwayland = true;
                float = true;
                fullscreen = false;
                pin = false;
              };

              no_focus = true;
            }
          ];

          general.border_size = 2;

          decoration = {
            rounding = 10;
            shadow.enabled = false;
          };

          animations.animation = [
            "windows, 1, 3, default, slide"
            "workspaces, 1, 3, default, slide"
          ];

          dwindle = {
            preserve_split = true;
          };

          input = {
            follow_mouse = 2;
            touchpad = {
              natural_scroll = true;
              clickfinger_behavior = true;
            };
          };

          ecosystem = {
            no_update_news = true;
            no_donation_nag = true;
          };
        }
        # smart gaps
        {
          workspace = [ "w[tv1], gapsout:0" ];
          windowrule = [ "match:workspace w[tv1], match:float false, rounding false, border_size 0" ];
        }
      ];
    };
  };
}
