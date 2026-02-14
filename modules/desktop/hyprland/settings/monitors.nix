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
          "DP-1, 2560x1440@300, 0x0, 1"
          "HDMI-A-1, 2560x1080@60, auto, 1"
        ];
      };
    };
    vidhan-macbook.homeModule = {
      wayland.windowManager.hyprland.settings = {
        monitor = [
          "eDP-1, preferred, 0x0, 1.6"
        ];
      };
    };
  };
}
