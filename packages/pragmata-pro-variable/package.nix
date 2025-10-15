{ lib, stdenvNoCC }:

stdenvNoCC.mkDerivation {
  pname = "pragmata-pro-variable";
  version = "0.9";

  src = fetchGit {
    url = "git@github.com:vidhanio/vidhanix-fonts";
    rev = "0804f7a3c5cd4f8d0ebf7832d03e03c0faa90bd9";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/truetype/
    cp fonts/pragmata-pro-variable/*.ttf $out/share/fonts/truetype/

    runHook postInstall
  '';

  meta = {
    description = "Condensed monospaced font optimized for screen, designed by Fabrizio Schiavi to be the ideal font for coding, math and engineering";
    homepage = "https://fsd.it/shop/fonts/pragmatapro-variable/";
    license = lib.licenses.unfree;
    platforms = lib.platforms.all;
  };
}
