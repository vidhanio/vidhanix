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
      hash = "sha256-t5Pi0SMg8hfkILINnpi0FT5MDmu7tUd65gXQR7V/ImY=";
    };
    "aarch64-linux" = {
      os = "linux-arm64";
      ext = "tar.gz";
      hash = "sha256-Fvcibp7/TjR7DdGrmhcJoKIts0g4fAhTnsQFD2V4T+o=";
    };
  };

  inherit (platforms.${system} or (throw "Unsupported system: ${system}")) os ext hash;
in
(vscode.override { isInsiders = true; }).overrideAttrs (
  finalAttrs: prevAttrs: {
    version = "1.108.0-insider-2025-12-12";
    commit = "9ba40f8204f1b4cb092f9585b19ab3f26d0a588c";

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
