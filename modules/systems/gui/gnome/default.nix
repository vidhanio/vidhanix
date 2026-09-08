{
  flake.aspects.gnome = {
    nixos =
      { pkgs, ... }:
      {
        services.desktopManager.gnome.enable = true;

        environment.gnome.excludePackages = with pkgs; [
          gnome-tour
          decibels
          epiphany
          geary
          gnome-text-editor
          gnome-calculator
          gnome-calendar
          gnome-characters
          gnome-font-viewer
          gnome-clocks
          gnome-console
          gnome-contacts
          gnome-logs
          gnome-maps
          gnome-music
          gnome-weather
          loupe
          papers
          gnome-connections
          showtime
          simple-scan
          snapshot
          yelp
        ];

      };

    homeManager = {
      dconf.settings."org/gnome/desktop/peripherals/mouse".accel-profile = "flat";
    };
  };
}
