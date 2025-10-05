{
  services = {
    displayManager.gdm.enable = true;
  };

  programs.dconf = {
    enable = true;
    profiles.gdm.databases = [
      {
        settings = {
          "org/gnome/desktop/peripherals/mouse" = {
            accel-profile = "flat";
          };
        };
      }
    ];
  };

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };
}
