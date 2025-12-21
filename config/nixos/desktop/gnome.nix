{ pkgs, lib, ... }:
{
  services = {
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
  ];

  programs.dconf = {
    enable = true;
    profiles =
      with lib.gvariant;
      let
        mkDatabases = settings: {
          databases = [
            { inherit settings; }
          ];
        };
      in
      lib.mapAttrs (_: mkDatabases) {
        user = {
          "org/gnome/desktop/wm/keybindings" = {
            switch-applications = mkEmptyArray type.string;
            switch-applications-backward = mkEmptyArray type.string;
          };

          "org/gnome/desktop/peripherals/mouse" = {
            accel-profile = "flat";
          };

          "org/gtk/gtk4/settings/file-chooser" = {
            show-hidden = true;
          };

          "org/gnome/nautilus/preferences" = {
            default-folder-viewer = "icon-view";
            recursive-search = "always";
            search-filter-time-type = "last_modified";
            show-directory-item-counts = "always";
            show-image-thumbnails = "always";
          };
        };
        gdm = {
          "org/gnome/desktop/peripherals/mouse" = {
            accel-profile = "flat";
          };
        };
      };
  };

  programs.kdeconnect = {
    enable = true;
    package = pkgs.gnomeExtensions.gsconnect;
  };
}
