let
  pkg =
    {
      lib,
      stdenvNoCC,
      fetchzip,
      nix-update-script,
    }:
    stdenvNoCC.mkDerivation (finalAttrs: {
      pname = "pi-anthropic-auth";
      version = "3.5.0";

      src = fetchzip {
        url = "https://registry.npmjs.org/@gotgenes/pi-anthropic-auth/-/pi-anthropic-auth-${finalAttrs.version}.tgz";
        hash = "sha256-24cHF/GcZNDy9Xub9Z4QPPphZ/qXHzatoZKWEaTeElQ=";
      };

      dontBuild = true;

      installPhase = ''
        runHook preInstall

        mkdir -p "$out/lib/node_modules/pi-anthropic-auth"
        cp -r src package.json README.md CHANGELOG.md LICENSE "$out/lib/node_modules/pi-anthropic-auth/"

        runHook postInstall
      '';

      passthru.updateScript = nix-update-script { };

      meta = {
        description = "Pi extension package for Anthropic OAuth compatibility";
        homepage = "https://github.com/gotgenes/pi-anthropic-auth";
        license = lib.licenses.mit;
        platforms = lib.platforms.all;
      };
    });
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages.pi-anthropic-auth = pkgs.callPackage pkg { };
    };
}
