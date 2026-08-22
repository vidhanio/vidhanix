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
    homeManager =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        home.pointerCursor = {
          enable = true;
          hyprcursor.enable = true;
        };

        wayland.windowManager.hyprland.settings.config.cursor.no_hardware_cursors = true;

        # reload the running hyprcursor when the theme files are relinked
        xdg.dataFile."icons/${config.home.pointerCursor.name}".onChange = ''
          for i in $(${pkgs.hyprland}/bin/hyprctl instances | sed -n 's/^instance \([^:]*\):/\1/p'); do
            ${pkgs.hyprland}/bin/hyprctl -i "$i" setcursor ${lib.escapeShellArg config.home.pointerCursor.name} ${toString config.home.pointerCursor.hyprcursor.size} || true
          done
        '';
      };
  };
}
