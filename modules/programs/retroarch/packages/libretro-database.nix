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
        version = "Latest-unstable-2026-02-23";

        src = fetchFromGitHub {
          owner = "libretro";
          repo = "libretro-super";
          rev = "132afcff7fc2c4be9f08cfa1ed3be24d10992aa5";
          hash = "sha256-EiyILEXiHknQZqLLL7M2GRukeEYM/3Z+I9KKVhQv+d8=";
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
      version = "1.22.1-unstable-2026-03-06";

      src = fetchFromGitHub {
        owner = "libretro";
        repo = "libretro-database";
        rev = "61a9d07cf7972b31f8198e30a01293661f4858af";
        hash = "sha256-fiZkBj4hIR3FYorLa4lCaeaBGkOhS3PEbUKyp6k/aCQ=";
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
