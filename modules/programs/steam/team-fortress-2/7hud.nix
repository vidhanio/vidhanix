let
  pkg =
    {
      lib,
      stdenvNoCC,
      fetchFromGitHub,
      nix-update-script,
    }:
    stdenvNoCC.mkDerivation {
      pname = "7hud";
      version = "5.16.2";

      src = fetchFromGitHub {
        owner = "Sevin7";
        repo = "7hud";
        rev = "v5.16.2";
        hash = "sha256-2OtkgRhQJghy7hRhQT2eLJ9T4gSdnLu2VteNBUtMdUc=";
      };

      dontConfigure = true;
      dontBuild = true;

      installPhase = ''
        runHook preInstall

        cp -a . "$out/"

        runHook postInstall
      '';

      passthru.updateScript = nix-update-script { };

      meta = {
        description = "7HUD for Team Fortress 2";
        homepage = "https://github.com/Sevin7/7hud";
        license = lib.licenses.unfreeRedistributable;
        platforms = lib.platforms.linux;
      };
    };
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages._7hud = pkgs.callPackage pkg { };
    };
}
