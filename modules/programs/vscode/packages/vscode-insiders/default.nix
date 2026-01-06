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
          hash = "sha256-mmQU0Nm8193GrbYKOKzOE9koiD/QiSs77qwoXdjY77Q=";
        };
        "aarch64-linux" = {
          os = "linux-arm64";
          hash = "sha256-QPawsjPnZBRAh86pMYGSmydP8RssT5PEbdNRM/3h74o=";
        };
      };

      inherit (platforms.${system} or (throw "Unsupported system: ${system}")) os hash;
    in
    (vscode.override { isInsiders = true; }).overrideAttrs (
      finalAttrs: prevAttrs: {
        version = "1.108.0-insider-2026-01-05";
        commit = "1cd32455f84020ce777b4b7d95df0a4b47b07015";

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
