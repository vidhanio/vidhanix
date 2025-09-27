{
  services = {
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };
}
