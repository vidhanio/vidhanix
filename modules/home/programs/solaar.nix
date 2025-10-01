{
  lib,
  pkgs,
  osConfig,
  ...
}:
lib.mkIf (builtins.elem pkgs.solaar osConfig.environment.systemPackages) {
  xdg.autostart.entries = [ "${pkgs.solaar}/share/autostart/solaar.desktop" ];
}
