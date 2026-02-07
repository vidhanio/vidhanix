{ lib, ... }:
{
  flake.modules.homeManager.default = {
    wayland.windowManager.hyprland.settings = {
      monitor = lib.mkDefault [
        ", preferred, auto, 1"
      ];

      misc.vrr = 1;
    };
  };

  configurations = {
    vidhan-pc.homeModule = {
      wayland.windowManager.hyprland.settings = {
        monitor = [
          "DP-1, 2560x1440@300, auto, 1"
        ];
      };
    };
    vidhan-macbook.homeModule = {
      wayland.windowManager.hyprland.settings = {
        monitor = [
          "eDP-1, preferred, auto, 1.6"
        ];
      };
    };
  };
}
