let
  pkg =
    {
      lib,
      stdenvNoCC,
      vidhan-fonts,
    }:
    stdenvNoCC.mkDerivation {
      pname = "berkeley-mono-variable";
      version = "2.003";

      src = vidhan-fonts;

      installPhase = ''
        runHook preInstall

        mkdir -p $out/share/fonts/opentype/
        cp berkeley-mono-variable/*.otf $out/share/fonts/opentype/

        runHook postInstall
      '';

      meta = {
        description = "A love letter to the golden era of computing";
        homepage = "https://usgraphics.com/products/berkeley-mono";
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
      packages.berkeley-mono-variable = pkgs.callPackage pkg {
        inherit (inputs) vidhan-fonts;
      };
    };
}
