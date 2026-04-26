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
          hash = "sha256-pscQd/52dvaJE4/p+sj99OnF3RN1UdDVByp3efeOZps=";
        };
        aarch64-linux = {
          arch = "arm64";
          hash = "sha256-6vQZAShQgfyJzCFvpG6mWCwB8w3i8EqR0EvfYNcnK+M=";
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
          version = "1.118.0-insider-2026-04-24";
          commit = "f2b51f3f64f0a781a7633c2243cfdde589030e34";

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
