{ lib, ... }:
{
  flake.aspects.hyprland = {
    homeManager =
      { pkgs, ... }:
      {
        binds = {
          "SUPER + Q".hyprland.dsp."window.close" = { };
          "SUPER + M".exec = "uwsm stop";
          "SUPER + V".exec = "noctalia msg panel-toggle clipboard";
          "SUPER + J".hyprland.dsp.layout = "togglesplit";
          "SUPER + F".hyprland.dsp."window.fullscreen" = { };

          "Print".exec = "noctalia msg screenshot-region";
          "SHIFT + Print".exec = "${lib.getExe pkgs.hyprpicker} -a";
          "SUPER + P".exec = "noctalia msg screenshot-region";
          "SUPER + I".exec = "${lib.getExe pkgs.hyprpicker} -a";

          "SUPER + mouse:272".hyprland.dsp = {
            "window.drag" = { };
            _flags.mouse = true;
          };
          "SUPER + mouse:273".hyprland.dsp = {
            "window.resize" = { };
            _flags.mouse = true;
          };
        };
      };
  };
}
