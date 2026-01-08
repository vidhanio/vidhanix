let
  pkg =
    {
      lib,
      stdenvNoCC,
      vidhan-fonts,
    }:
    stdenvNoCC.mkDerivation {
      name = "google-sans-flex";

      src = vidhan-fonts;

      installPhase = ''
        runHook preInstall

        install -Dm644 google-sans-flex/*.ttf -t $out/share/fonts/truetype

        runHook postInstall
      '';

      meta = {
        description = "The next generation of Google's brand typeface";
        homepage = "https://fonts.google.com/specimen/Google+Sans+Flex";
        license = lib.licenses.ofl;
        platforms = lib.platforms.all;
      };
    };
in
{ inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.google-sans-flex = pkgs.callPackage pkg {
        inherit (inputs) vidhan-fonts;
      };
    };
}
