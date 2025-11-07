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
    enable = osCfg.enable;
    extensions =
      with pkgs.gnomeExtensions;
      map (package: { inherit package; }) [
        appindicator
        dash-to-panel
        pip-on-top
        rounded-window-corners-reborn
        steal-my-focus-window
        solaar-extension
      ];
  };

  dconf.settings = {
    "org/gnome/shell/extensions/dash-to-panel" = {
      scroll-icon-action = "PASS_THROUGH";
      scroll-panel-action = "NOTHING";
    };
  };

  persist.directories = lib.mkIf osConfig.services.gnome.gnome-keyring.enable [
    ".local/share/keyrings"
  ];
}
