{
  flake.modules.homeManager.default =
    let
      noctalia = "noctalia-shell ipc call";
    in
    {
      wayland.windowManager.hyprland.settings = {
        bind = [
          "SUPER, L, exec, loginctl lock-session"
        ];
      };

      services.hypridle = {
        enable = true;
        settings = {
          general = {
            lock_cmd = "${noctalia} lockScreen lock";
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
              timeout = 330;
              on-timeout = "hyprctl dispatch dpms off";
              on-resume = "hyprctl dispatch dpms on";
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
