{ pkgs, ... }:
{
  home.packages = with pkgs; [ spotify ];

  xdg.autostart.entries = with pkgs; [ "${spotify}/share/applications/spotify.desktop" ];

  impermanence.directories = [
    ".config/spotify"
  ];
}
