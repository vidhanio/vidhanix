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
      hash = "sha256-WYhunoj9biNXlX3oVMVttCV9U6k0FNBKYgjKhEGGGmk=";
    };
    "aarch64-linux" = {
      os = "linux-arm64";
      ext = "tar.gz";
      hash = "sha256-3yHw7F2LPxQYvKdHV4BkBQw4b38yOl+1Akr+T/57PqM=";
    };
  };

  inherit (platforms.${system} or (throw "Unsupported system: ${system}")) os ext hash;
in
(vscode.override { isInsiders = true; }).overrideAttrs (
  finalAttrs: prevAttrs: {
    version = "1.108.0-insider-2025-12-18";
    commit = "b76549b5cda03bc1ec8e84f44c51fa7ec590a310";

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
