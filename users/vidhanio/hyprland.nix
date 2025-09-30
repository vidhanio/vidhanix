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

      decoration = {
        rounding = 10;
      };
    };
  };
}
