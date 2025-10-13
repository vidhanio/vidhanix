{
  stdenv,
  vscode,
  fetchurl,
}:
let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  systems = {
    "x86_64-linux" = {
      os = "linux-x64";
      ext = "tar.gz";
      hash = "sha256-GBB3xngPo7yXApHcSesMlY8hx75TSIQWJ3cbO9QiO6I=";
    };
    "aarch64-darwin" = {
      os = "darwin-arm64";
      ext = "zip";
      hash = "sha256-r1yxM4zCEIOzqu3J7arfMKVC6stja/sv4w2NmM9GJ7M=";
    };
  };

  version = "bf56edffb59c43fa0de636c3aa1d548770b168b8";

  inherit (systems.${system} or throwSystem) os ext hash;
in
(vscode.override { isInsiders = true; }).overrideAttrs {
  inherit version;

  src = fetchurl {
    name = "vscode-insiders-${version}-${os}.${ext}";
    url = "https://update.code.visualstudio.com/commit:${version}/${os}/insider";
    inherit hash;
  };

  passthru.updateScript = ./update.sh;

  meta.platforms = [
    "x86_64-linux"
    "aarch64-darwin"
  ];
}
