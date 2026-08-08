{ lib, ... }:
{
  flake.modules = {
    homeManager.default =
      { pkgs, ... }:
      {
        hyprland.binds = {
          "SUPER + Q"."window.close" = { };
          "SUPER + M".exec_cmd = "uwsm stop";
          "SUPER + V".exec_cmd = "noctalia msg panel-toggle clipboard";
          "SUPER + J".layout = "togglesplit";
          "SUPER + F"."window.fullscreen" = { };

          "Print".exec_cmd = "${lib.getExe pkgs.grimblast} --freeze copy area";
          "SHIFT + Print".exec_cmd = "${lib.getExe pkgs.hyprpicker} -a";

          # move/resize windows with SUPER + LMB/RMB and dragging
          "SUPER + mouse:272" = {
            "window.drag" = { };
            _flags.mouse = true;
          };
          "SUPER + mouse:273" = {
            "window.resize" = { };
            _flags.mouse = true;
          };
        };
      };
  };
}
