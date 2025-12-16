{
  stdenv,
  lib,
  vscode,
  fetchurl,
  curl,
  openssl,
  webkitgtk_4_1,
  libsoup_3,
}:
let
  inherit (stdenv.hostPlatform) system;

  platforms = {
    "x86_64-linux" = {
      os = "linux-x64";
      ext = "tar.gz";
      hash = "sha256-M9D1W/fjdNTy9Z8flaCAh3YAcNniKA8CDFlaN4OfBvQ=";
    };
    "aarch64-linux" = {
      os = "linux-arm64";
      ext = "tar.gz";
      hash = "sha256-Q5Ye2XF9SuELj0sS+0S8rDalPUsRqs5VngPWJ4XEtr8=";
    };
  };

  inherit (platforms.${system} or (throw "Unsupported system: ${system}")) os ext hash;
in
(vscode.override { isInsiders = true; }).overrideAttrs (
  finalAttrs: prevAttrs: {
    version = "1.108.0-insider-2025-12-15";
    commit = "0d1ac13bc4847cf870373727f12ae70ad6c6e500";

    src = fetchurl {
      name = "vscode-insiders-${finalAttrs.commit}-${os}.${ext}";
      url = "https://update.code.visualstudio.com/commit:${finalAttrs.commit}/${os}/insider";
      inherit hash;
    };

    buildInputs = prevAttrs.buildInputs or [ ] ++ [
      curl
      openssl
      webkitgtk_4_1
      libsoup_3
    ];

    passthru.updateScript = ./update.sh;

    meta = prevAttrs.meta // {
      platforms = lib.attrNames platforms;
    };
  }
)
