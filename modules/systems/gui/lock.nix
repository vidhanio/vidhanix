_: {
  flake.aspects.lock = {
    nixos = {
      security.pam.services.hyprlock = { };
    };

    homeManager =
      { osConfig, config, ... }:
      let
        decorationCfg = config.wayland.windowManager.hyprland.settings.config.decoration;
      in
      {
        binds."SUPER + L".exec = "loginctl lock-session";

        programs.hyprlock = {
          enable = true;

          settings.input-field = {
            monitor = osConfig.hardware.monitors.main.name;

            size = "20%, 5%";
            placeholder_text = "";

            # match hyprland/noctalia
            inherit (decorationCfg) rounding;
            outline_thickness = 0;
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
                  on-timeout = "loginctl lock-session";
                }
                {
                  # turn off screen 5 seconds after manual lock
                  timeout = 5;
                  condition_cmd = "pidof hyprlock";
                  condition_retry = 1;
                  on-timeout = dpms "disable";
                  on-resume = dpms "enable";
                }
              ];
            };
        };
      };
  };
}
