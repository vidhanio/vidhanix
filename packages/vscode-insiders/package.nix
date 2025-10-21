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
      hash = "sha256-M43boL6zO6M6MOXHw6mmFiiWoUySgUErHq2TqTBAevs=";
    };
    "aarch64-linux" = {
      os = "linux-arm64";
      ext = "tar.gz";
      hash = "sha256-ZPLD2+z2LX4C07SGN5AvduyztzW8CjGPWILs12+Mh14=";
    };
  };

  inherit (platforms.${system} or (throw "Unsupported system: ${system}")) os ext hash;
in
(vscode.override { isInsiders = true; }).overrideAttrs (
  finalAttrs: previousAttrs: {
    version = "latest";
    commit = "afecaaa7e88b2be589fc99ff1566c058b7fae906";

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
