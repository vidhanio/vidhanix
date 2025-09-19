{ pkgs, lib, ... }:
{
  programs.vesktop.enable = true;

  xdg.autostart.entries = with pkgs; map lib.getDesktop [ vesktop ];

  impermanence.directories = [
    ".config/vesktop"
  ];
}
