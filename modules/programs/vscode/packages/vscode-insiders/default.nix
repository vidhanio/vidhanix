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
          arch = "x64";
          hash = "sha256-zrrwEsvElpZMOVleQKgnvcbZQsuClsaUP9W5V7OfyX8=";
        };
        aarch64-linux = {
          arch = "arm64";
          hash = "sha256-Rw2oNWL9fSw2XblsVrsW52felZa47TYI3eHUXBAuM2Y=";
        };
      };

      inherit (platforms.${system} or (throw "Unsupported system: ${system}")) arch hash;
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
          version = "1.124.0-insider-2026-06-08";
          commit = "77dfb21e210c8be0d72ab995889cbc7e4a9ae468";

          src = fetchurl {
            name = "vscode-insiders-${finalAttrs.commit}-linux-${arch}.tar.gz";
            url = "https://update.code.visualstudio.com/commit:${finalAttrs.commit}/linux-${arch}/insider";
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
