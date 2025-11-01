final: prev: {
  qgnomeplatform-qt6 = prev.qgnomeplatform-qt6.overrideAttrs (previousAttrs: {
    patches = previousAttrs.patches or [ ] ++ [
      (final.fetchurl {
        # https://github.com/NixOS/nixpkgs/pull/455370
        url = "https://raw.githubusercontent.com/NixOS/nixpkgs/master/pkgs/development/libraries/qgnomeplatform/qt6_10.patch";
        hash = "sha256-PmKqTflTlHwmLTxwCVUVPZubG+L4jRZZaH1CGQFH+bw=";
      })
    ];
  });
}
