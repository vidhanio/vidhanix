{ lib, ... }:
{
  flake.aspects.hyprland = {
    homeManager =
      { pkgs, ... }:
      {
        wayland.windowManager.hyprland.binds = {
          "SUPER + Q"."window.close" = { };
          "SUPER + M".exec_cmd = "uwsm stop";
          "SUPER + V".exec_cmd = "noctalia msg panel-toggle clipboard";
          "SUPER + J".layout = "togglesplit";
          "SUPER + F"."window.fullscreen" = { };

          "Print".exec_cmd = "noctalia msg screenshot-region";
          "SHIFT + Print".exec_cmd = "${lib.getExe pkgs.hyprpicker} -a";
          "SUPER + P".exec_cmd = "noctalia msg screenshot-region";
          "SUPER + I".exec_cmd = "${lib.getExe pkgs.hyprpicker} -a";

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
