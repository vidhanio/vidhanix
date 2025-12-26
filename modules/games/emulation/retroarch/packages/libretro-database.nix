{
  inputs,
  lib,
  ...
}:
{
  perSystem =
    {
      self',
      pkgs,
      ...
    }:
    {
      packages.libretro-database =
        let
          inherit (inputs) libretro-database libretro-super;
          inherit (pkgs) stdenvNoCC;
          inherit (self'.packages) libretrodb_tool;
        in
        stdenvNoCC.mkDerivation {
          name = "libretro-database";

          src = libretro-database;

          postUnpack = ''
            mkdir -p $sourceRoot/libretro-super
            cp ${libretro-super}/libretro-build-database.sh $sourceRoot/libretro-super/
          '';

          postPatch = ''
            patchShebangs libretro-super/libretro-build-database.sh
            substituteInPlace libretro-super/libretro-build-database.sh \
              --replace-fail  ''\'''${BASE_DIR}/''${LIBRETRODB_BASE_DIR}/c_converter' "${lib.getExe' libretrodb_tool "c_converter"}"
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
    };
}
