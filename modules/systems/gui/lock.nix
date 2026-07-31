{
  flake.modules = {
    nixos.default = {
      security.pam.services.hyprlock = { };
    };

    homeManager.default =
      { osConfig, ... }:
      {
        hyprland.binds."SUPER + L".exec_cmd = "loginctl lock-session";

        programs.hyprlock = {
          enable = true;

          settings = {
            input-field = {
              monitor = osConfig.hardware.monitors.main.name;

              size = "20%, 5%";

              # match hyprland/noctalia
              rounding = 8;
              outline_thickness = 4;

              fade_on_empty = false;
              dots_spacing = 0.3;

              position = "0, 0";
              halign = "center";
              valign = "center";
            };
          };
        };

        services.hypridle = {
          enable = true;
          settings =
            let
              dpms = action: "hyprctl dispatch 'hl.dsp.dpms({ action = \"${action}\" })'";
            in
            {
              general = {
                lock_cmd = "pidof hyprlock || hyprlock";
                before_sleep_cmd = "loginctl lock-session";
                after_sleep_cmd = dpms "enable";
              };
              listener = [
                {
                  timeout = 300;
                  on-timeout = "loginctl lock-session && ${dpms "disable"}";
                  on-resume = dpms "enable";
                }
                {
                  # turn off screen 5 seconds after manual lock
                  timeout = 5;
                  condition_cmd = "pidof hyprlock";
                  on-timeout = dpms "disable";
                  on-resume = dpms "enable";
                }
              ];
            };
        };
      };
  };
}
