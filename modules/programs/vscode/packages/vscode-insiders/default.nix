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
          hash = "sha256-EVPtdRLCLS0gOYBxDoYaINGNQAOOtzOz0ebgK07/E8E=";
        };
        aarch64-linux = {
          arch = "arm64";
          hash = "sha256-oRaRSbvsDQP9YQqvqKmOn+o1CHelIis2qS+vrZSWRSg=";
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
          version = "1.130.0-insider-2026-07-20";
          commit = "d4434528dd269c894c309379dbc26f48d4a3f803";

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
