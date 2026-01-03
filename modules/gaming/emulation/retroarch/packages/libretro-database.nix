let
  pkg =
    {
      lib,
      stdenvNoCC,

      libretro-database-src,
      libretro-super,
      libretrodb-tool,
    }:
    stdenvNoCC.mkDerivation {
      name = "libretro-database";

      src = libretro-database-src;

      postUnpack = ''
        mkdir -p $sourceRoot/libretro-super
        cp ${libretro-super}/libretro-build-database.sh $sourceRoot/libretro-super/
      '';

      postPatch = ''
        patchShebangs libretro-super/libretro-build-database.sh
        substituteInPlace libretro-super/libretro-build-database.sh \
          --replace-fail  ''\'''${BASE_DIR}/''${LIBRETRODB_BASE_DIR}/c_converter' "${lib.getExe' libretrodb-tool "c_converter"}"
      '';

      makeFlags = [ "PREFIX=$(out)" ];

      buildPhase = ''
        runHook preBuild

        mkdir -p ./libretro-super/retroarch/{libretro-db,media/libretrodb}
        make $makeFlags build

        runHook postBuild
      '';

      meta = {
        description = "Databases used by RetroArch";
        homepage = "https://github.com/libretro/libretro-database";
        platforms = lib.platforms.all;
      };
    };
in
{ inputs, ... }:
{

  flake-file.inputs = {
    libretro-super = {
      url = "github:libretro/libretro-super";
      flake = false;
    };
    libretro-database-src = {
      url = "github:libretro/libretro-database";
      flake = false;
    };
  };

  perSystem =
    { self', pkgs, ... }:
    {
      packages.libretro-database = pkgs.callPackage pkg {
        inherit (inputs) libretro-database-src libretro-super;
        inherit (self'.packages) libretrodb-tool;
      };
    };
}
