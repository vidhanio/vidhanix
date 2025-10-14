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
      hash = "sha256-i1MFtqfWiAsvxgyc/MZlOdo/Py6PQlJmjHGeYnhygso=";
    };
    "aarch64-linux" = {
      os = "linux-arm64";
      ext = "tar.gz";
      hash = "jdoiwjoidjoijwoi";
    };
    "x86_64-darwin" = {
      os = "darwin";
      ext = "zip";
      hash = "sha256-1v6m7mYHk0rYp+1e4bX6k1m3nU5r3n5f1g8gXh3p2m4=";
    };
    "aarch64-darwin" = {
      os = "darwin-arm64";
      ext = "zip";
      hash = "sha256-IDqupYgoslZb7Po8nimOTwojTJ0TO5efgfTqtTQ+dUI=";
    };
  };

  version = "03c265b1adee71ac88f833e065f7bb956b60550a";

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
