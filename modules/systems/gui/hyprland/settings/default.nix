{
  den.default.homeManager = {
    wayland.windowManager.hyprland.settings = {
      window_rule = [
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
        # smart gaps
        {
          name = "no-gaps-f1";

          match = {
            workspace = "f[1]";
            float = false;
          };

          rounding = 0;
          border_size = 0;
        }
      ];

      # smart gaps
      workspace_rule = [
        {
          workspace = "f[1]";
          gaps_in = 0;
          gaps_out = 0;
        }
      ];

      config = {
        general = {
          border_size = 2;
          gaps_in = 4;
          gaps_out = 8;
        };

        decoration.shadow.enabled = false;

        dwindle.preserve_split = true;

        input = {
          follow_mouse = 2;
          repeat_rate = 50;
          repeat_delay = 500;
          touchpad = {
            natural_scroll = true;
            clickfinger_behavior = true;
          };
        };

        ecosystem = {
          no_update_news = true;
          no_donation_nag = true;
        };
      };

      animation = [
        {
          leaf = "windows";
          enabled = true;
          speed = 3;
          bezier = "default";
          style = "popin";
        }
        {
          leaf = "workspaces";
          enabled = true;
          speed = 3;
          bezier = "default";
          style = "slide";
        }
      ];
    };
  };
}
