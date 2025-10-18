{
  lib,
  pkgs,
  osConfig,
  ...
}:
lib.mkIf (lib.elem pkgs.solaar osConfig.environment.systemPackages) {
  xdg.autostart.entries = [ "${pkgs.solaar}/share/applications/solaar-autostart.desktop" ];
}
