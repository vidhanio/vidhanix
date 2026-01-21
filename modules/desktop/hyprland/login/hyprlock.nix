{ lib, ... }:
{
  flake.modules.homeManager.default =
    {
      config,
      osConfig,
      ...
    }:
    let
      uwsm = lib.getExe osConfig.programs.uwsm.package;
      hyprlock = lib.getExe config.programs.hyprlock.package;
      hyprctl = lib.getExe' osConfig.programs.hyprland.package "hyprctl";
    in
    {
      programs.hyprlock.enable = true;

      wayland.windowManager.hyprland.settings = {
        bind = [
          "SUPER, L, exec, ${uwsm} app -- ${hyprlock}"
        ];
      };

      services.hypridle = {
        enable = true;
        settings = {
          general = {
            lock_cmd = "pidof hyprlock || ${uwsm} app -- '${hyprlock}'";
            before_sleep_cmd = "loginctl lock-session";
            after_sleep_cmd = "${hyprctl} dispatch dpms on";
          };

          listener = [
            {
              timeout = 300;
              on-timeout = "loginctl lock-session";
            }
            {
              # turn off screen in 30 seconds after locking
              timeout = 30;
              on-timeout = "pidof hyprlock && ${hyprctl} dispatch dpms off";
              on-resume = "${hyprctl} dispatch dpms on";
            }
            {
              timeout = 1800;
              on-timeout = "systemctl suspend";
            }
          ];
        };
      };
    };
}
