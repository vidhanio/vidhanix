{
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = lib.readSubmodules ./.;

  stylix = {
    enable = true;
    polarity = "dark";
    image =
      with config.lib.stylix.colors.withHashtag;
      pkgs.replaceVars ./wallpaper.svg {
        bg = base00;

        purple = base0E;
        black = base01;
        red = base08;

        ball = base04;

        claws = base07;
        teeth = base07;
        eye = base07;
      };
    base16Scheme = "${pkgs.base16-schemes}/share/themes/horizon-terminal-dark.yaml";
    fonts = {
      monospace = {
        package = pkgs.berkeley-mono-variable;
        name = "Berkeley Mono Variable";
      };
      serif = config.stylix.fonts.monospace;
      sansSerif = {
        package = pkgs.rubik;
        name = "Rubik";
      };
    };
  };
}
