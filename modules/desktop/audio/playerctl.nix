{ lib, ... }:
{
  flake.modules = {
    nixos.default = {
      services.playerctld.enable = true;
    };
    homeManager.default =
      { osConfig, ... }:
      {
        wayland.windowManager.hyprland.settings.bindl =
          let
            playerctl = lib.getExe osConfig.services.playerctld.package;
          in
          [
            ", XF86AudioPrev, exec, ${playerctl} previous"
            ", XF86AudioNext, exec, ${playerctl} next"
            ", XF86AudioPause, exec, ${playerctl} play-pause"
            ", XF86AudioPlay, exec, ${playerctl} play-pause"
          ];
      };
  };
}
