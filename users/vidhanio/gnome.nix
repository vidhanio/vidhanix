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
      ];
  };

  impermanence.directories =
    lib.mkIf (lib.elem pkgs.gnome-keyring osConfig.environment.systemPackages)
      [ ".local/share/keyrings" ];
}
