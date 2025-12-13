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
        gsconnect
      ];
  };

  persist.directories = lib.mkIf osConfig.services.gnome.gnome-keyring.enable [
    ".local/share/keyrings"
  ];
}
