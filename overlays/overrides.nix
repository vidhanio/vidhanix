final: prev: {
  solaar = prev.solaar.overrideAttrs (oldAttrs: {
    postInstall = oldAttrs.postInstall or "" + ''
      mkdir -p $out/share/autostart
      cp $src/share/autostart/solaar.desktop $out/share/autostart/solaar.desktop
    '';
  });
}
