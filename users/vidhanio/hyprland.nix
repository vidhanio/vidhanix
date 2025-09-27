{
  lib,
  osConfig,
  config,
  ...
}:
lib.mkIf osConfig.programs.hyprland.enable or false {
  xdg.configFile."uwsm/env".source =
    "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      monitor = ", preferred, auto, auto";

      "$terminal" = "ghostty";

      exec-once = "$terminal";

      "$mainMod" = "SUPER";
      bind = [
        "$mainMod, Q, exec, $terminal"
      ];
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      decoration = {
        rounding = 10;
      };
    };
  };
}
