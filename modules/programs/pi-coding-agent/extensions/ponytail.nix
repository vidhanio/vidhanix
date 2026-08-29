let
  pkg =
    {
      lib,
      fetchFromGitHub,
      nix-update-script,
      stdenvNoCC,
    }:
    stdenvNoCC.mkDerivation (finalAttrs: {
      pname = "ponytail";
      version = "4.9.0";

      src = fetchFromGitHub {
        owner = "DietrichGebert";
        repo = "ponytail";
        tag = "v${finalAttrs.version}";
        hash = "sha256-8cYggVltBAlZ/Zj4pl1bOu7mQdZFXCmDGW4RSpvRA+w=";
      };

      dontBuild = true;

      installPhase = ''
        runHook preInstall
        mkdir -p $out
        cp -r package.json hooks pi-extension skills $out/
        runHook postInstall
      '';

      passthru.updateScript = nix-update-script {
        extraArgs = [ "--flake" ];
      };

      meta = {
        description = "Minimalist coding guidance plugin for AI agents";
        homepage = "https://github.com/DietrichGebert/ponytail";
        changelog = "https://github.com/DietrichGebert/ponytail/releases/tag/v${finalAttrs.version}";
        downloadPage = "https://www.npmjs.com/package/@dietrichgebert/ponytail";
        license = lib.licenses.mit;
        platforms = lib.platforms.all;
      };
    });
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages.ponytail = pkgs.callPackage pkg { };
    };
}
