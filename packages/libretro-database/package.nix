{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
  libretro-super,
  libretrodb_tool,
  extraSystems ? { },
}:
let
  extraSystemsText = lib.concatLines (
    lib.mapAttrsToList (
      system: crcKind:
      "build_libretro_database ${lib.escapeShellArg system} ${lib.escapeShellArg "crc.${crcKind}"};"
    ) extraSystems
  );
in
stdenvNoCC.mkDerivation {
  pname = "libretro-database";
  version = "1.22.1";

  src = fetchFromGitHub {
    owner = "libretro";
    repo = "libretro-database";
    rev = "fbcc8c1c24d8b20b6aaca95b4da6a2f39ad85f05";
    hash = "sha256-othU6KJQs2MgSbsZMo0AOmn0ykQT48athTf2EPJLSw4=";
  };

  postUnpack = ''
    mkdir -p $sourceRoot/libretro-super
    cp ${libretro-super.src}/libretro-build-database.sh $sourceRoot/libretro-super/
  '';

  postPatch = ''
    patchShebangs libretro-super/libretro-build-database.sh
    substituteInPlace libretro-super/libretro-build-database.sh \
      --replace-fail  ''\'''${BASE_DIR}/''${LIBRETRODB_BASE_DIR}/c_converter' "${lib.getExe' libretrodb_tool "c_converter"}"
    echo "${extraSystemsText}" >> libretro-super/libretro-build-database.sh
  '';

  makeFlags = [ "PREFIX=$(out)" ];

  buildPhase = ''
    runHook preBuild

    mkdir -p ./libretro-super/retroarch/{libretro-db,media/libretrodb}
    make $makeFlags build

    runHook postBuild
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
    ];
  };

  meta = {
    description = "Databases used by RetroArch";
    homepage = "https://github.com/libretro/libretro-database";
    platforms = lib.platforms.all;
  };
}
