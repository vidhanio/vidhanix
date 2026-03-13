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
          hash = "sha256-4RuBEqe/FObM6jFK2/lMIS57MtihS4ZqMgcqw0qpsy0=";
        };
        "aarch64-linux" = {
          os = "linux-arm64";
          hash = "sha256-EYkfHjRurY9xBJX2qMbf7A6LSanM5SFxAGsOUMJgTMM=";
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
          version = "1.112.0-insider-2026-03-13";
          commit = "5bf5b2ae5d859d7ec9ef4563cafc790a47ad3cc5";

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
