{
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  osCfg = osConfig.services.desktopManager.gnome;
  mkIfExists = lib.mkIf (osConfig ? services.desktopManager.gnome);
in
{
  programs.gnome-shell = {
    enable = mkIfExists osCfg.enable;
    extensions =
      with pkgs.gnomeExtensions;
      map (package: { inherit package; }) [
        appindicator
        blur-my-shell
        dash-to-panel
        pip-on-top
        rounded-window-corners-reborn
      ];
  };

  dconf.settings = mkIfExists {
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
        "firefox.desktop"
        "code-insiders.desktop"
        "vesktop.desktop"
        "cider-2.desktop"
      ];
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

  impermanence.directories =
    lib.mkIf (builtins.elem pkgs.gnome-keyring osConfig.environment.systemPackages)
      [ ".local/share/keyrings" ];
}
