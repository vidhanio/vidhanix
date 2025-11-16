{
  lib,
  stdenv,
  retroarch-bare,
}:
stdenv.mkDerivation {
  pname = "libretrodb_tool";
  inherit (retroarch-bare) version src;

  preBuild = ''
    cd libretro-db
  '';

  makeFlags = [ "PREFIX=$(out)" ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"

    cp c_converter dat_converter libretrodb_tool "$out/bin"

    runHook postInstall
  '';

  meta = {
    description = "Tools for managing libretro databases";
    mainProgram = "libretrodb_tool";
    homepage = "https://github.com/libretro/RetroArch/tree/master/libretro-db";
    inherit (retroarch-bare.meta) license;
    platforms = lib.platforms.all;
  };
}
