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
      hash = "sha256-1roQrlcnt0kbPIUtJgsqFhPPtaq8xpcaguIeE5mjFYM=";
    };
    "aarch64-linux" = {
      os = "linux-arm64";
      ext = "tar.gz";
      hash = "sha256-vieXLKM502Pp/B5GR1rYPkcRG4fDB9hOieO3H/NH4lQ=";
    };
  };

  inherit (platforms.${system} or (throw "Unsupported system: ${system}")) os ext hash;
in
(vscode.override { isInsiders = true; }).overrideAttrs (
  finalAttrs: previousAttrs: {
    version = "1.106.0-insider-2025-11-03";
    commit = "005cfa92907d127e9df88f4cdd0846c773ee663a";

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
