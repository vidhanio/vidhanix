final: prev: {
  solaar = prev.solaar.overrideAttrs (previousAttrs: {
    postInstall = previousAttrs.postInstall or "" + ''
      mkdir -p $out/share/autostart
      cp $src/share/autostart/solaar.desktop $out/share/autostart/solaar.desktop
    '';
  });

  # NixOS/nixpkgs#449396
  qgnomeplatform = prev.qgnomeplatform.overrideAttrs (previousAttrs: {
    cmakeFlags = (previousAttrs.cmakeFlags or [ ]) ++ [
      "-DCMAKE_POLICY_VERSION_MINIMUM=3.10"
    ];
  });
}
