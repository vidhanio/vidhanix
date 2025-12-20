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
          hash = "sha256-iDRX/3ilKc5LAneTtTtlfjHqIVdYTXeI4MlZeZNvf8g=";
        };
        "aarch64-linux" = {
          os = "linux-arm64";
          hash = "sha256-RUUWJHqARkCJvS8VYCKjF7+HELtIXn7J3JqQ0i60Gis=";
        };
      };

      inherit (platforms.${system} or (throw "Unsupported system: ${system}")) os hash;
    in
    (vscode.override { isInsiders = true; }).overrideAttrs (
      finalAttrs: prevAttrs: {
        version = "1.108.0-insider-2025-12-19";
        commit = "7f08f95ad54782bd242f5536470b330282197333";

        src = fetchurl {
          name = "vscode-insiders-${finalAttrs.commit}-${os}.tar.gz";
          url = "https://update.code.visualstudio.com/commit:${finalAttrs.commit}/${os}/insider";
          inherit hash;
        };

        passthru.updateScript = ./update.sh;

        meta = prevAttrs.meta // {
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
