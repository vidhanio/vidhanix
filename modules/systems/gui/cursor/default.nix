{
  flake.aspects.cursor = {
    nixos =
      { self', config, ... }:
      {
        stylix = {
          cursor = {
            package = self'.packages.bibata-combined.override (
              with config.lib.stylix.colors.withHashtag;
              {
                baseColor = base00;
                outlineColor = base05;
                palette = {
                  spinnerBlue = blue;
                  spinnerGreen = green;
                  spinnerRed = red;
                  spinnerYellow = yellow;
                  copy = green;
                  pin = cyan;
                  move = blue;
                  person = base02;
                  topLeftCorner = blue;
                  contextMenu = magenta;
                  link = base03;
                  bottomLeftCorner = green;
                  topRightCorner = orange;
                  ask = orange;
                  bottomRightCorner = yellow;
                  error = red;
                };
              }
            );
            name = "Bibata Cursor";
            size = 24;
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
