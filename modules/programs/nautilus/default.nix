{
  flake.aspects.nautilus = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.nautilus ];

        dconf.settings = {
          "org/gnome/nautilus/preferences" = {
            default-folder-viewer = "icon-view";
            migrated-gtk-settings = true;
            recursive-search = "always";
            search-filter-time-type = "last_modified";
            show-delete-permanently = true;
            show-directory-item-counts = "always";
            show-image-thumbnails = "always";
          };
          "org/gtk/gtk4/settings/file-chooser".show-hidden = true;
        };
      };
  };
}
