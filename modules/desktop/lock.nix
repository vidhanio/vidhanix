{
  flake.modules.homeManager.default = {
    wayland.windowManager.hyprland.settings = {
      bind = [
        "SUPER, L, exec, loginctl lock-session"
      ];
    };

    programs.hyprlock.enable = true;

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };

        listener = [
          {
            timeout = 300;
            on-timeout = "loginctl lock-session";
          }
          {
            # turn off screen in 30 seconds after locking
            timeout = 30;
            on-timeout = "pidof hyprlock && hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    };
  };
}
