{
  lib,
  osConfig,
  config,
  ...
}:
let
  osCfg = osConfig.programs.hyprland;
in
lib.mkIf (osConfig ? programs.hyprland) (
  lib.mkMerge [
    (lib.mkIf osCfg.withUWSM {
      xdg.configFile."uwsm/env".source =
        "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";
      wayland.windowManager.hyprland.systemd.enable = false;
    })
    {
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

          bindel = [
            ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
            ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ];
          bindl = [
            ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
            ", XF86AudioPlay, exec, playerctl play-pause"
            ", XF86AudioPrev, exec, playerctl previous"
            ", XF86AudioNext, exec, playerctl next"
          ];

          input.accel_profile = "flat";

          decoration = {
            rounding = 10;
          };
        };
      };
    }
  ]
)
