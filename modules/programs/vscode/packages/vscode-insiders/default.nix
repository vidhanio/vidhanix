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
        "x86_64-linux" = {
          os = "linux-x64";
          hash = "sha256-upLOEwcNtmn5/JKDBWRxHHcKumBupAVFAvb/pfpfiSs=";
        };
        "aarch64-linux" = {
          os = "linux-arm64";
          hash = "sha256-ppwTHdWdGDBcf9s0oA0hUc7/7NysZykfpOlfl6bkfxo=";
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
          version = "1.109.0-insider-2026-01-16";
          commit = "f46196091d2fa0069d229cb638869b4ab95392cf";

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
