{ pkgs, ... }:
{
  programs.vesktop.enable = true;

  xdg.autostart.entries = with pkgs; [ "${vesktop}/share/applications/vesktop.desktop" ];

  impermanence.directories = [
    ".config/vesktop"
  ];
}
