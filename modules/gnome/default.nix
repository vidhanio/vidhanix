{ pkgs, ... }:
{
  flake.modules.nixos.default = {
    services = {
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };

    environment.gnome.excludePackages = with pkgs; [
      gnome-tour
    ];
  };
}
