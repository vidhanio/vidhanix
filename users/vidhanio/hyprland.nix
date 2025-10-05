{
  lib,
  osConfig,
  config,
  ...
}:
let
  osCfg = osConfig.programs.hyprland;
in
lib.mkIf (osConfig ? programs.hyprland) {
  xdg.configFile."uwsm/env".source =
    lib.mkIf osCfg.withUWSM "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";

  wayland.windowManager.hyprland = {
    enable = osCfg.enable;
    package = null;
    portalPackage = null;

    systemd.enable = lib.mkIf osCfg.withUWSM false;

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
      bindle = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-"
      ];

      input.accel_profile = "flat";

      decoration = {
        rounding = 10;
      };
    };
  };
}
