{
  flake.modules.nixos.default =
    { pkgs, ... }:
    {
      services = {
        displayManager.gdm.enable = true;
        desktopManager.gnome.enable = true;
      };

      environment.gnome.excludePackages = with pkgs; [
        gnome-tour
        decibels
        epiphany
        gnome-text-editor
        gnome-calculator
        gnome-calendar
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
}
