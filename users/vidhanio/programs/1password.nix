{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [ _1password-gui ];

  xdg.autostart.entries = with pkgs; map lib.getDesktop [ _1password-gui ];

  impermanence.directories = [ ".config/1Password" ];
}
