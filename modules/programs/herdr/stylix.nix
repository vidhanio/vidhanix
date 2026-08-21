{
  flake.aspects.herdr = {
    homeManager =
      { config, ... }:
      {
        programs.herdr.settings.theme.custom = with config.lib.stylix.colors.withHashtag; {
          accent = base0D;

          panel_bg = base01;
          sidebar_bg = "reset";
          active_row_bg = base00;
          selection_bg = base02;

          surface0 = base02;
          surface1 = base03;
          surface_dim = base00;

          overlay0 = base04;
          overlay1 = base04;
          text = base05;
          subtext0 = base04;

          mauve = base0E;
          green = base0B;
          yellow = base0A;
          red = base08;
          blue = base0D;
          teal = base0C;
          peach = base09;
        };
      };
  };
}
