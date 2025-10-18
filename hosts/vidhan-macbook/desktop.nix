{ pkgs, ... }: {
  services = {
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
  ];

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
}