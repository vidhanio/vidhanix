{ lib, ... }:
let
  bind = keys: dispatcher: {
    _args = [
      keys
      (lib.generators.mkLuaInline dispatcher)
      {
        repeating = true;
        locked = true;
      }
    ];
  };
in
{
  flake.modules = {
    nixos.default =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          pkgs.brightnessctl
        ];
      };
    homeManager.default = {
      wayland.windowManager.hyprland.settings.bind = [
        (bind "XF86MonBrightnessDown" ''hl.dsp.exec_cmd("brightnessctl s 10%-")'')
        (bind "XF86MonBrightnessUp" ''hl.dsp.exec_cmd("brightnessctl s +10%")'')
      ];
    };
  };
}
