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
          hash = "sha256-cGCVXQUg17aMrO3ZqGKP3zPQJLERgXMfD4lkTzBRxWw=";
        };
        "aarch64-linux" = {
          os = "linux-arm64";
          hash = "sha256-eYviZ0grTZKiB2h2QO/KKIACTb8V0VWlAoyYAoCbnZk=";
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
          version = "1.109.0-insider-2026-01-30";
          commit = "ea084045c1ea954f98f53a5a7c31a85a1877b100";

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
