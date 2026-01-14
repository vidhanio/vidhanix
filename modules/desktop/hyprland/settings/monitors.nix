{ lib, ... }:
{
  flake.modules.homeManager.default = {
    wayland.windowManager.hyprland.settings = {
      monitor = lib.mkDefault [
        ", preferred, auto, 1"
      ];

      workspace = [
        "name:main, default:true"
      ];

      misc.vrr = 1;
    };
  };

  configurations.vidhan-pc.homeModule = {
    wayland.windowManager.hyprland.settings = {
      monitor = [
        #          ┌─────┐
        #          │     │
        #          │     │
        # ┌────────┤     │
        # │        │     │
        # └────────┴─────┘
        "DP-1, 2560x1440@300, 0x0, 1"
        "HDMI-A-1, 2560x1080@60, 2560x-1120, 1, transform, 3"
      ];

      workspace = [
        # workspaces
        "name:main, monitor:DP-1"
        "name:games, monitor:DP-1"

        "name:side, monitor:HDMI-A-1, default:true"
      ];
    };
  };
}
