{ lib, ... }:
{
  flake.aspects.niri.homeManager = { config, ... }: {
    wayland.windowManager.niri.settings._children = lib.mkBefore [
      {
        window-rule = {
          geometry-corner-radius = config.stylix.cornerRadius;
          clip-to-geometry = true;
        };
      }
    ];
  };
}
