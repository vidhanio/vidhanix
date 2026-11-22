{
  profiles.pc = {
    module =
      { self', config, ... }:
      {
        stylix = {
          cursor = {
            package = self'.packages.bibata-combined.override (
              with config.lib.stylix.colors.withHashtag;
              {
                baseColor = base01;
                outlineColor = base06;
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

        # PAM applies these before greetd execs the compositor.
        environment.sessionVariables = {
          XCURSOR_THEME = config.stylix.cursor.name;
          XCURSOR_SIZE = toString config.stylix.cursor.size;
          HYPRCURSOR_THEME = config.stylix.cursor.name;
          HYPRCURSOR_SIZE = toString config.stylix.cursor.size;
        };
      };
    homeModule =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        home.pointerCursor = {
          hyprcursor.enable = true;
          x11.enable = true;
        };

        xdg.dataFile."icons/${config.home.pointerCursor.name}".onChange = ''
          for i in $(${lib.getExe' pkgs.hyprland "hyprctl"} instances | sed -n 's/^instance \([^:]*\):/\1/p'); do
            ${lib.getExe' pkgs.hyprland "hyprctl"} -i "$i" setcursor ${lib.escapeShellArg config.home.pointerCursor.name} ${toString config.home.pointerCursor.hyprcursor.size} || true
          done
        '';
      };
  };
}
