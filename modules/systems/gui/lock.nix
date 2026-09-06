_: {
  flake.aspects.lock = {
    nixos = {
      security.pam.services.hyprlock = { };
    };

    homeManager =
      { osConfig, config, ... }:
      {
        binds."SUPER + L".exec = "loginctl lock-session";

        programs.hyprlock = {
          enable = true;

          settings.input-field = {
            monitor = osConfig.hardware.monitors.main.name;

            size = "20%, 5%";
            placeholder_text = "";

            rounding = config.stylix.cornerRadius;
            outline_thickness = config.stylix.borderThickness;
          };
        };

        services.hypridle = {
          enable = true;
          settings =
            let
              dpms =
                action:
                let
                  niriCommand = if action == "disable" then "niri msg action power-off-monitors" else "true";
                in
                "case \"$XDG_CURRENT_DESKTOP\" in *niri*) ${niriCommand} ;; *) hyprctl dispatch 'hl.dsp.dpms({ action = \"${action}\" })' ;; esac";
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
