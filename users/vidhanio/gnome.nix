{ pkgs, ... }:
{
  programs.gnome-shell = {
    enable = true;
    extensions =
      with pkgs.gnomeExtensions;
      map (package: { inherit package; }) [
        appindicator
        dash-to-dock
        pip-on-top
      ];
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };

    "org/gnome/desktop/wm/keybindings" = {
      switch-applications = [ ];
      switch-applications-backward = [ ];
      switch-windows = [ "<Alt>Tab" ];
      switch-windows-backward = [ "<Shift><Alt>Tab" ];
    };
    "org/gnome/shell" = {
      favorite-apps = [
        "org.gnome.Nautilus.desktop"
        "com.mitchellh.ghostty.desktop"
        "firefox-devedition.desktop"
        "code-insiders.desktop"
        "vesktop.desktop"
        "cider-2.desktop"
      ];
      welcome-dialog-last-shown-version = "48.4";
    };

    "org/gtk/gtk4/settings/file-chooser" = {
      show-hidden = true;
    };

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "icon-view";
      migrated-gtk-settings = true;
      recursive-search = "always";
      search-filter-time-type = "last_modified";
      show-directory-item-counts = "always";
      show-image-thumbnails = "always";
    };

  };

  impermanence.directories = [ ".local/share/keyrings/" ];
}
