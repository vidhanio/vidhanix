{ pkgs, ... }:
{
  home.packages = with pkgs; [ _1password-gui ];

  xdg.autostart.entries = with pkgs; [ "${_1password-gui}/share/applications/1password.desktop" ];

  impermanence.directories = [ ".config/1Password" ];
}
