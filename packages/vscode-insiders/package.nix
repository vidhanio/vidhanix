{
  stdenv,
  lib,
  vscode,
  fetchurl,
}:
let
  inherit (stdenv.hostPlatform) system;

  platforms = {
    "x86_64-linux" = {
      os = "linux-x64";
      ext = "tar.gz";
      hash = "sha256-minJbcUkEIU4SRNXsC2hvlOel+1gtV3uBQsXHOSD998=";
    };
    "aarch64-linux" = {
      os = "linux-arm64";
      ext = "tar.gz";
      hash = "sha256-Tw9vLn3NeLH3CCtmQfiT7TvpZu1ook0uT+HZLp8GN+U=";
    };
  };

  inherit (platforms.${system} or (throw "Unsupported system: ${system}")) os ext hash;
in
(vscode.override { isInsiders = true; }).overrideAttrs (
  finalAttrs: previousAttrs: {
    version = "1.106.0-insider-2025-11-06";
    commit = "402271f5deb7fc29b000463cfa525fc8c03fb7d7";

    src = fetchurl {
      name = "vscode-insiders-${finalAttrs.commit}-${os}.${ext}";
      url = "https://update.code.visualstudio.com/commit:${finalAttrs.commit}/${os}/insider";
      inherit hash;
    };

    passthru.updateScript = ./update.sh;

    meta = previousAttrs.meta // {
      platforms = lib.attrNames platforms;
    };
  }
)
