{ pkgs, ... }:
{
  stylix = {
    enable = true;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/ayu-dark.yaml";
    fonts = {
      monospace = {
        package = pkgs.berkeley-mono-variable;
        name = "Berkeley Mono Variable";
      };
    };
  };
}
