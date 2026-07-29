{
  flake.modules.homeManager.default = {
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

      # https://docs.noctalia.dev/v5/compositor-settings/hyprland/
      config = {
        general = {
          border_size = 2;
          gaps_in = 4;
          gaps_out = 8;
        };

        decoration = {
          rounding = 8;

          shadow.enabled = false;
          blur.enabled = false;
        };

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

        xwayland = {
          force_zero_scaling = true;
        };
      };
    };
  };
}
