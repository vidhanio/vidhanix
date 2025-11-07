{ config, pkgs, ... }:
{
  stylix = {
    enable = true;
    polarity = "dark";
    image = config.lib.stylix.pixel "base00";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/horizon-terminal-dark.yaml";
    fonts = {
      monospace = {
        package = pkgs.berkeley-mono-variable;
        name = "Berkeley Mono Variable";
      };
      serif = config.stylix.fonts.monospace;
      sansSerif = {
        package = pkgs.inter;
        name = "Inter";
      };
    };
  };
}
