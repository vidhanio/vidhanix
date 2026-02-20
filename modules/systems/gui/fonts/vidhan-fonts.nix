{ lib, inputs, ... }:
{
  flake-file.inputs.vidhan-fonts = {
    url = "git+ssh://git@github.com/vidhanio/fonts";
    flake = false;
  };

  perSystem =
    { pkgs, ... }:
    let
      mkVidhanFontPackage =
        pname:
        {
          version,
          meta,
        }:
        pkgs.callPackage (
          {
            lib,
            stdenvNoCC,
            vidhan-fonts,
          }:
          stdenvNoCC.mkDerivation {
            inherit pname version;

            src = vidhan-fonts;

            installPhase = ''
              runHook preInstall

              for f in ${pname}/*; do
                case "$f" in
                  *.ttf) install -Dm644 "$f" -t $out/share/fonts/truetype ;;
                  *.otf) install -Dm644 "$f" -t $out/share/fonts/opentype ;;
                esac
              done

              runHook postInstall
            '';

            meta = meta // {
              platforms = lib.platforms.all;
            };
          }
        ) { inherit (inputs) vidhan-fonts; };
    in
    {
      packages = lib.mapAttrs mkVidhanFontPackage {
        pragmata-pro-variable = {
          version = "0.9";
          meta = {
            description = "Condensed monospaced font optimized for screen, designed by Fabrizio Schiavi to be the ideal font for coding, math and engineering";
            homepage = "https://fsd.it/shop/fonts/pragmatapro-variable/";
            license = lib.licenses.unfree;
          };
        };
        google-sans-flex = {
          version = "197067";
          meta = {
            description = "The next generation of Google's brand typeface";
            homepage = "https://fonts.google.com/specimen/Google+Sans+Flex";
            license = lib.licenses.ofl;
          };
        };
        berkeley-mono-variable = {
          version = "2.004";
          meta = {
            description = "A love letter to the golden era of computing";
            homepage = "https://usgraphics.com/products/berkeley-mono";
            license = lib.licenses.unfree;
          };
        };
        berkeley-mono = {
          version = "2.004";
          meta = {
            description = "A love letter to the golden era of computing";
            homepage = "https://usgraphics.com/products/berkeley-mono";
            license = lib.licenses.unfree;
          };
        };
      };
    };
}
