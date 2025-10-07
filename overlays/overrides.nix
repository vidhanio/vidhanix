final: prev: {
  solaar = prev.solaar.overrideAttrs (previousAttrs: {
    postInstall = previousAttrs.postInstall or "" + ''
      mkdir -p $out/share/autostart
      cp $src/share/autostart/solaar.desktop $out/share/autostart/solaar.desktop
    '';
  });
}
