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
      hash = "sha256-buifk8oJ0qaLf4Dg9tW6eQDtu32GKOwKe1gTq9tIEjI=";
    };
    "aarch64-linux" = {
      os = "linux-arm64";
      ext = "tar.gz";
      hash = "sha256-bcLLMg4FkpDsquZR5l8lID312/jOoT34tn2u0QiYsVk=";
    };
    "aarch64-darwin" = {
      os = "darwin-arm64";
      ext = "zip";
      hash = "sha256-6fgeD24cnPKBsUo8WDSJ8lEqqjrkjA9CACGXiAjlr/s=";
    };
  };

  inherit (platforms.${system} or (throw "Unsupported system: ${system}")) os ext hash;
in
(vscode.override { isInsiders = true; }).overrideAttrs (
  finalAttrs: previousAttrs: {
    version = "latest";
    commit = "9722262df14632ac3c1f167a7b162a12a5bee509";

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
