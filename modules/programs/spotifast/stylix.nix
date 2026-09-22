{
  flake.aspects.spotifast = {
    homeManager =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        colors = config.lib.stylix.colors.withHashtag;
        theme = "stylix.json";
        themeFile = pkgs.writeText theme (
          lib.toJSON {
            base = if config.stylix.polarity == "dark" then "dark" else "light";
            colors = with colors; {
              window = base00;
              panel = base00;
              surface = base02;
              surface_hover = base03;
              surface_active = base04;
              outline = base03;
              text = base05;
              secondary = base04;
              dim = base03;
              accent = base0D;
              accent_hover = base0D;
              on_accent = base00;
              danger = base08;
              warning = base0A;
              overlay = base01;
            };
          }
        );
      in
      {
        programs.spotifast.settings.custom_theme = theme;

        home.activation.spotifastTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          run ${lib.getExe' pkgs.coreutils "install"} -Dm644 ${themeFile} "${config.xdg.configHome}/spotifast/themes/${theme}"
        '';
      };
  };
}
