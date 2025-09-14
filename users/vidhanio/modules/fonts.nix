{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # berkeley-mono-variable
    # pragmata-pro-variable
    jetbrains-mono
  ];

  fonts.fontconfig.enable = true;
}
