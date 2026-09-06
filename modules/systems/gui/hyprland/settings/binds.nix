{ lib, ... }:
{
  flake.aspects.hyprland = {
    homeManager =
      { pkgs, ... }:
      {
        binds = {
          "SHIFT + Print" = {
            hyprland.dsp.exec_cmd = "${lib.getExe pkgs.hyprpicker} -a";
            niri.enable = false;
          };
          "SUPER + I" = {
            hyprland.dsp.exec_cmd = "${lib.getExe pkgs.hyprpicker} -a";
            niri.enable = false;
          };

          "SUPER + mouse:272" = {
            hyprland.dsp = {
              "window.drag" = { };
              _flags.mouse = true;
            };
            niri.enable = false;
          };
          "SUPER + mouse:273" = {
            hyprland.dsp = {
              "window.resize" = { };
              _flags.mouse = true;
            };
            niri.enable = false;
          };
        };
      };
  };
}
