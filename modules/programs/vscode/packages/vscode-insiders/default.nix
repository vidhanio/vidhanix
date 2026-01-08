let
  pkg =
    {
      stdenvNoCC,
      lib,
      vscode,
      fetchurl,
    }:
    let
      inherit (stdenvNoCC.hostPlatform) system;

      platforms = {
        "x86_64-linux" = {
          os = "linux-x64";
          hash = "sha256-Zhl9pSscc+QaFrN0joKWvNxKlx9CCjcbFDy8O0/IScc=";
        };
        "aarch64-linux" = {
          os = "linux-arm64";
          hash = "sha256-84GVPiS2vBATOD/nfNu1db/oawSqJsOqEosIvIjD5bQ=";
        };
      };

      inherit (platforms.${system} or (throw "Unsupported system: ${system}")) os hash;
    in
    (vscode.override { isInsiders = true; }).overrideAttrs (
      finalAttrs: prevAttrs: {
        version = "1.108.0-insider-2026-01-07";
        commit = "3d862df21449d5ead0b0b1fbe6d43eb05490cb1c";

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
