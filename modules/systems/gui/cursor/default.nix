{
  flake.aspects.cursor = {
    nixos =
      { self', config, ... }:
      {
        stylix = {
          cursor = {
            package = self'.packages.breezex-combined.override (
              with config.lib.stylix.colors.withHashtag;
              {
                baseColor = base01;
                outlineColor = base07;
              }
            );
            name = "BreezeX Cursor";
            size = 32;
          };
        };
      };
    homeManager = {
      home.pointerCursor = {
        enable = true;
        hyprcursor.enable = true;
      };

      wayland.windowManager.hyprland.settings.config.cursor.no_hardware_cursors = true;
    };
  };
}
