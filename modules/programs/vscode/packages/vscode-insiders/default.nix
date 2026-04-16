let
  pkg =
    {
      stdenv,
      lib,
      vscode,
      fetchurl,
      ...
    }@args:
    let
      inherit (stdenv.hostPlatform) system;

      platforms = {
        x86_64-linux = {
          os = "linux-x64";
          hash = "sha256-ndzOX1VnYBDh5qjeo8EFxkIZvJ1iOPBEOKwJCZpTkA0=";
        };
        aarch64-linux = {
          os = "linux-arm64";
          hash = "sha256-830CCha4/LxvkBLJA4i4I+dT6nI6l+nj7qZVPpHg9zE=";
        };
      };

      inherit (platforms.${system} or (throw "Unsupported system: ${system}")) os hash;
    in
    (vscode.override (
      {
        isInsiders = true;
      }
      // (lib.removeAttrs args [
        "stdenv"
        "lib"
        "vscode"
        "fetchurl"
      ])
    )).overrideAttrs
      (
        finalAttrs: prevAttrs: {
          version = "1.116.0-insider-2026-04-13";
          commit = "1dfb3b9dd41665724360e94791708dfcab81b681";

          src = fetchurl {
            name = "vscode-insiders-${finalAttrs.commit}-${os}.tar.gz";
            url = "https://update.code.visualstudio.com/commit:${finalAttrs.commit}/${os}/insider";
            inherit hash;
          };

          passthru.updateScript = ./update.sh;

          meta = prevAttrs.meta // {
            mainProgram = "code-insiders";
            platforms = lib.attrNames platforms;
          };
        }
      );
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages.vscode-insiders = pkgs.callPackage pkg { };
    };
}
