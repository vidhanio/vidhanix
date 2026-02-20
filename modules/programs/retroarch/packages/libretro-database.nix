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
        version = "Latest-unstable-2026-02-11";

        src = fetchFromGitHub {
          owner = "libretro";
          repo = "libretro-super";
          rev = "3588fe15046ba177f34a00d99e4a6044476de66d";
          hash = "sha256-cYXJbWS7bQIy/6EIhMQY5w1qgtPJZ3PC8jPBzVkXet4=";
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
      version = "1.22.1-unstable-2026-02-15";

      src = fetchFromGitHub {
        owner = "libretro";
        repo = "libretro-database";
        rev = "4c856a61cdff938e5f440b8f5f4b042accee1d24";
        hash = "sha256-eV9ELTiP3wLm6tOJeKlAJ1FbVm7I+Wx5x0jAzMVSb3o=";
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
