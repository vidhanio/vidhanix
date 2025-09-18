{ config, lib, ... }:
{
  services = lib.mkIf (config.specialisation != { }) {
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  specialisation.plasma.configuration.services = {
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    desktopManager.plasma6.enable = true;
  };
}
