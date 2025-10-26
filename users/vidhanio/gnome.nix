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
      ];
  };

  dconf.settings = {
    "org/gnome/shell/extensions/dash-to-panel" = {
      scroll-icon-action = "PASS_THROUGH";
      scroll-panel-action = "NOTHING";
    };
  };

  impermanence.directories =
    lib.mkIf (lib.elem pkgs.gnome-keyring osConfig.environment.systemPackages)
      [ ".local/share/keyrings" ];
}
