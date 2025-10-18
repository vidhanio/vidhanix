final: prev: {
  solaar = prev.solaar.overrideAttrs (previousAttrs: {
    postInstall = previousAttrs.postInstall or "" + ''
      cp $src/share/autostart/solaar.desktop $out/share/applications/solaar-autostart.desktop
    '';
  });
}
