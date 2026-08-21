{ lib, ... }: {
  flake.aspects.lock = {
    nixos = {
      security.pam.services.hyprlock = { };
    };

    homeManager =
      { osConfig, config, ... }:
      let
        decorationCfg = config.wayland.windowManager.hyprland.settings.config.decoration;
        blurCfg = decorationCfg.blur;
      in
      {
        hyprland.binds."SUPER + L".exec_cmd = "loginctl lock-session";

        stylix.targets.hyprlock.image.enable = false;

        programs.hyprlock = {
          enable = true;

          settings = {
            background = {
              path = "screenshot";
              blur_size = blurCfg.size;
              blur_passes = blurCfg.passes;
              inherit (blurCfg) vibrancy vibrancy_darkness;
            };
            input-field = {
              monitor = osConfig.hardware.monitors.main.name;

              size = "20%, 5%";
              placeholder_text = "";

              inner_color =
                with config.lib.stylix.colors;
                lib.mkForce "rgba(${toString base00-rgb-r}, ${toString base00-rgb-g}, ${toString base00-rgb-b}, ${toString config.stylix.opacity.desktop})";

              # match hyprland/noctalia
              inherit (decorationCfg) rounding;
              outline_thickness = 0;
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
