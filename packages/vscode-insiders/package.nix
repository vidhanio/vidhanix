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
      hash = "sha256-tDgsFSM99hW6BrSZuqEF2B0KnNc5VtBa/dflrzT10KA=";
    };
    "aarch64-linux" = {
      os = "linux-arm64";
      ext = "tar.gz";
      hash = "sha256-tRMAEyQlP/SdhIe3ZxTV8ApXp+vSQTstKDE1QO2GqAU=";
    };
  };

  inherit (platforms.${system} or (throw "Unsupported system: ${system}")) os ext hash;
in
(vscode.override { isInsiders = true; }).overrideAttrs (
  finalAttrs: previousAttrs: {
    version = "1.107.0-insider-2025-11-14";
    commit = "18279e23d7d90c429d329c1104d2108d388b8210";

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
