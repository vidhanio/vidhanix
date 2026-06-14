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
          hash = "sha256-Ri+LN+tnry8MLr4fsvuNftdM5HGeI9/7oANBpSOqjlw=";
        };
        aarch64-linux = {
          arch = "arm64";
          hash = "sha256-5my4gCzfnM3cMFYY30elfcX6vdT0gMPuPr0O1dXRRlQ=";
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
          version = "1.125.0-insider-2026-06-12";
          commit = "43a13cad7f4d7c1f0c87dd6459bb6d85f394d5fb";

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
