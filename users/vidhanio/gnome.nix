{
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  osCfg = osConfig.services.desktopManager.gnome;
in
{
  programs.gnome-shell = {
    enable = lib.mkIf (osConfig ? services.desktopManager.gnome) osCfg.enable;
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

  dconf.settings = {
    "org/gnome/desktop/wm/keybindings" = {
      switch-applications = [ ];
      switch-applications-backward = [ ];
      switch-windows = [ "<Alt>Tab" ];
      switch-windows-backward = [ "<Shift><Alt>Tab" ];
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

    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "flat";
    };
  };

  impermanence.directories =
    lib.mkIf (lib.elem pkgs.gnome-keyring osConfig.environment.systemPackages)
      [ ".local/share/keyrings" ];
}
