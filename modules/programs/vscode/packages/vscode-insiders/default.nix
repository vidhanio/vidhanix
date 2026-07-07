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
          hash = "sha256-UHpKF4VLEn/YOH/f+loY/GQeyrv2trbKhiSVth5M/to=";
        };
        aarch64-linux = {
          arch = "arm64";
          hash = "sha256-2glCM2gXEO0eY4dZt6iPCxiivfEwJi1Pr5nyUu/RF88=";
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
          version = "1.127.0-insider-2026-06-26";
          commit = "628f6de50e89b20c7688c66ac2923cce2862c1b0";

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
