{
  flake.aspects.fastpotify = {
    homeManager =
      {
        config,
        inputs',
        pkgs,
        ...
      }:
      let
        colors = config.lib.stylix.colors;

        rgb =
          name:
          "Color32::from_rgb(${colors."${name}-rgb-r"}, ${colors."${name}-rgb-g"}, ${colors."${name}-rgb-b"})";

        stylixPatch = pkgs.replaceVars ./stylix.patch {
          base00 = rgb "base00";
          base01 = rgb "base01";
          base02 = rgb "base02";
          base03 = rgb "base03";
          base04 = rgb "base04";
          base05 = rgb "base05";
          base08 = rgb "base08";
          base0A = rgb "base0A";
          base0D = rgb "base0D";
        };

        defaultTheme =
          if config.stylix.polarity == "light" then
            "light"
          else if config.stylix.polarity == "either" then
            "system"
          else
            "dark";
      in
      {
        # fastpotify compiles its palette into the binary rather than reading a theme file.
        programs.fastpotify = {

          package = inputs'.fastpotify.packages.fastpotify.overrideAttrs (old: {
            patches = (old.patches or [ ]) ++ [ stylixPatch ];
          });
          settings.theme = defaultTheme;
        };
      };
  };
}
