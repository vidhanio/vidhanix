let
  pkg =
    {
      lib,
      stdenvNoCC,
      libretrodb-tool,
      fetchFromGitHub,
      nix-update-script,
      _experimental-update-script-combinators,
    }:
    let
      libretro-super = stdenvNoCC.mkDerivation {
        pname = "libretro-super";
        version = "Latest-unstable-2026-07-25";

        src = fetchFromGitHub {
          owner = "libretro";
          repo = "libretro-super";
          rev = "4c4d6f289abc5bc257db04d600868636dad6c649";
          hash = "sha256-FK31Wrqrbj8RjhF+ZHIgo9Cnn1bnH37sIODCchNom/c=";
        };

        phases = [
          "unpackPhase"
          "installPhase"
        ];

        installPhase = ''
          cp -r . $out
        '';
      };
    in
    stdenvNoCC.mkDerivation {
      pname = "libretro-database";
      version = "1.22.1-unstable-2026-07-04";

      src = fetchFromGitHub {
        owner = "libretro";
        repo = "libretro-database";
        rev = "9aec58983a73ba4370ba6fd7c1b7d915ec56dda6";
        hash = "sha256-/DY4c5Wz5XsNWdtQDOLD0QjAWWCDnFhzanw53kS4+q8=";
      };

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

      passthru = {
        super = libretro-super;

        updateScript = _experimental-update-script-combinators.sequence [
          (nix-update-script {
            extraArgs = [
              "--flake"
              "--version=branch"
            ];
          })
          (nix-update-script {
            extraArgs = [
              "--flake"
              "--version=branch"
              "libretro-database.super"
            ];
          })
        ];
      };

      meta = {
        description = "Databases used by RetroArch";
        homepage = "https://github.com/libretro/libretro-database";
        platforms = lib.platforms.all;
      };
    };
in
{
  perSystem =
    { self', pkgs, ... }:
    {
      packages.libretro-database = pkgs.callPackage pkg {
        inherit (self'.packages) libretrodb-tool;
      };
    };
}
