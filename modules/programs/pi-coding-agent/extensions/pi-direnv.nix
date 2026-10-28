let
  pkg =
    {
      lib,
      stdenvNoCC,
      fetchzip,
      nix-update-script,
    }:
    stdenvNoCC.mkDerivation (finalAttrs: {
      pname = "pi-direnv";
      version = "0.1.0";

      src = fetchzip {
        url = "https://registry.npmjs.org/pi-direnv/-/pi-direnv-${finalAttrs.version}.tgz";
        hash = "sha256-QV20kgIox6qH6m9BLQWiaKA8F+IQ8G02qDxRXzg1/GA=";
      };

      dontBuild = true;

      installPhase = ''
        runHook preInstall

        mkdir -p "$out/lib/node_modules/pi-direnv"
        cp index.ts package.json README.md "$out/lib/node_modules/pi-direnv/"

        runHook postInstall
      '';

      passthru.updateScript = nix-update-script {
        extraArgs = [ "--flake" ];
      };

      meta = {
        description = "Automatically load direnv environments at Pi session start";
        homepage = "https://pi.dev/packages/pi-direnv";
        license = lib.licenses.mit;
        platforms = lib.platforms.all;
      };
    });
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages.pi-direnv = pkgs.callPackage pkg { };
    };

  profiles.pc.homeModule =
    { self', ... }:
    {
      programs.pi-coding-agent.settings.packages = [
        "${self'.packages.pi-direnv}/lib/node_modules/pi-direnv"
      ];
    };
}
