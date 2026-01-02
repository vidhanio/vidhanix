let
  pkg =
    {
      lib,
      stdenvNoCC,
      fonts,
    }:
    stdenvNoCC.mkDerivation {
      pname = "pragmata-pro-variable";
      version = "0.9";

      src = fonts;

      installPhase = ''
        runHook preInstall

        mkdir -p $out/share/fonts/truetype/
        cp $pname/*.ttf $out/share/fonts/truetype/

        runHook postInstall
      '';

      meta = {
        description = "Condensed monospaced font optimized for screen, designed by Fabrizio Schiavi to be the ideal font for coding, math and engineering";
        homepage = "https://fsd.it/shop/fonts/pragmatapro-variable/";
        license = lib.licenses.unfree;
        platforms = lib.platforms.all;
      };
    };
in
{ inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.pragmata-pro-variable = pkgs.callPackage pkg {
        inherit (inputs) fonts;
      };
    };
}
