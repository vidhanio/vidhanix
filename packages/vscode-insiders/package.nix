{
  stdenv,
  vscode,
  fetchurl,
}:
let
  inherit (stdenv.hostPlatform) system;

  platforms = {
    "x86_64-linux" = {
      os = "linux-x64";
      ext = "tar.gz";
      hash = "sha256-WkxSrnHFPfX7tfLfUCD08Xc5To9GON83FqMrsfkEOkE=";
    };
    "aarch64-linux" = {
      os = "linux-arm64";
      ext = "tar.gz";
      hash = "sha256-EFR8gu6kZbYeTBTu10ZKjLPjxRpB9m301gIxxiG3N2E=";
    };
    "aarch64-darwin" = {
      os = "darwin-arm64";
      ext = "zip";
      hash = "sha256-PIB2Po5tC446fvYJzJRKvwFE+AGQB2WotF8dyM9RPsI=";
    };
  };

  inherit (platforms.${system} or (throw "Unsupported system: ${system}")) os ext hash;
in
(vscode.override { isInsiders = true; }).overrideAttrs (
  finalAttrs: previousAttrs: {
    version = "latest";
    commit = "f030344cf19e76e6b47d2d8ab003780a7fdb8171";

    src = fetchurl {
      name = "vscode-insiders-${finalAttrs.commit}-${os}.${ext}";
      url = "https://update.code.visualstudio.com/commit:${finalAttrs.commit}/${os}/insider";
      inherit hash;
    };

    passthru.updateScript = ./update.sh;

    meta = previousAttrs.meta // {
      platforms = builtins.attrNames platforms;
    };
  }
)
