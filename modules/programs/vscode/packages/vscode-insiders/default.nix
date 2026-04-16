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
          hash = "sha256-db7T2RdPje+6fV1GZNkdLE2mtWR3wLq5KyY/0ml6eZo=";
        };
        aarch64-linux = {
          os = "linux-arm64";
          hash = "sha256-48O8fCzz06G4XZJE4ZhidM+7BmYElv1Xy1+qqTtLCHs=";
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
          version = "1.117.0-insider-2026-04-16";
          commit = "4ab3ca5546cf2df8c15361f1ebda6444f1e0c7a1";

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
