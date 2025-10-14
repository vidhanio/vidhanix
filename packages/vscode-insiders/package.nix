{
  stdenv,
  vscode,
  fetchurl,
}:
let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  platforms = {
    "x86_64-linux" = {
      os = "linux-x64";
      ext = "tar.gz";
      hash = "sha256-oDqnjeDapBykcCNepOenGsoch6z0zi75cxe3ugPZGos=";
    };
    "aarch64-linux" = {
      os = "linux-arm64";
      ext = "tar.gz";
      hash = "sha256-ELlIgnMuE/HANs3FSqFIXpGTHQwmvmjGhYmM2J69adI=";
    };
    "aarch64-darwin" = {
      os = "darwin-arm64";
      ext = "zip";
      hash = "sha256-z+l55N3f9ypNWYm1zUfRCgohQEiZfNVpeeJyJNIno0E=";
    };
  };

  version = "359fa23b39bb37e5157e99c2bc5fc81088dd8431";

  inherit (platforms.${system} or throwSystem) os ext hash;
in
(vscode.override { isInsiders = true; }).overrideAttrs {
  inherit version;

  src = fetchurl {
    name = "vscode-insiders-${version}-${os}.${ext}";
    url = "https://update.code.visualstudio.com/commit:${version}/${os}/insider";
    inherit hash;
  };

  passthru.updateScript = ./update.sh;

  meta.platforms = builtins.attrNames platforms;
}
