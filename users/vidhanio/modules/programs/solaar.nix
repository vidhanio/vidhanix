{
  lib,
  pkgs,
  osConfig,
  ...
}:
lib.optionalAttrs osConfig.nixpkgs.hostPlatform.isLinux {
  home.packages = with pkgs; [ solaar ];

  xdg.autostart.entries = with pkgs; [ "${solaar}/share/applications/solaar.desktop" ];
}
