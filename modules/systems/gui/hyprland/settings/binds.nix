{ lib, ... }:
{
  flake.modules = {
    homeManager.default =
      { pkgs, ... }:
      {
        wayland.windowManager.hyprland.settings = {
          bind = [
            "SUPER, Q, killactive,"
            "SUPER, M, exec, uwsm stop"
            "SUPER, V, togglefloating,"
            "SUPER, J, togglesplit,"
            "SUPER, F, fullscreen,"

            # screenshot
            ", Print, exec, ${lib.getExe pkgs.grimblast} copy area"
          ];

          bindm = [
            # move/resize windows with SUPER + LMB/RMB and dragging
            "SUPER, mouse:272, movewindow"
            "SUPER, mouse:273, resizewindow"
          ];
        };
      };
  };
}
