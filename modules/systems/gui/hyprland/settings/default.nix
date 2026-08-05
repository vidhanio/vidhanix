{
  flake.modules.homeManager.default = {
    wayland.windowManager.hyprland.settings = {
      window_rule = [
        {
          match.class = ".*";

          suppress_event = "maximize";
        }
        {
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
          layout = "master";
          border_size = 2;
          gaps_in = 4;
          gaps_out = 8;
        };
        decoration = {
          rounding = 8;
          blur = {
            size = 3;
            passes = 2;
          };
        };

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

        misc = {
          disable_splash_rendering = true;
        };

        xwayland = {
          force_zero_scaling = true;
        };
      };
    };
  };
}
