{
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  solaar = pkgs.solaar.overrideAttrs (oldAttrs: {
    postInstall = oldAttrs.postInstall + ''
      mkdir -p $out/share/autostart
      cp $src/share/autostart/solaar.desktop $out/share/autostart/solaar.desktop
    '';
  });
in
lib.optionalAttrs osConfig.nixpkgs.hostPlatform.isLinux {
  home.packages = [ solaar ];

  xdg.autostart.entries = [ "${solaar}/share/autostart/solaar.desktop" ];
}
