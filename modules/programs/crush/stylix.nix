{
  # Vendored from github:vidhanio/stylix (vidhanio) modules/crush/hm.nix.
  flake.aspects.crush.homeManager =
    { config, ... }:
    {
      programs.crush.settings.options.tui = {
        active_theme = "stylix";

        theme.stylix = with config.lib.stylix.colors.withHashtag; {
          base = "charmtone";

          primary = base0D;
          secondary = base0E;
          accent = base0F;
          keyword = base0E;

          fg_base = base05;
          fg_subtle = base04;
          fg_more_subtle = base03;
          fg_most_subtle = base02;

          bg_base = base00;
          bg_most_visible = base02;
          bg_less_visible = base01;
          bg_least_visible = base00;

          on_primary = base00;
          separator = base03;

          destructive = base08;
          error = base08;
          warning = base0A;
          warning_subtle = base09;
          attention = base09;
          busy = base0A;
          info = base0C;
          info_more_subtle = base0C;
          info_most_subtle = base0C;
          success = base0B;
          success_more_subtle = base0B;
          success_most_subtle = base0B;
        };
      };
    };
}
