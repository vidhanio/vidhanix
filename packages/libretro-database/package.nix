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
  version = "1.22.1-unstable-2025-12-18";

  src = fetchFromGitHub {
    owner = "libretro";
    repo = "libretro-database";
    rev = "a9fdad51b33be81a47643ab23c551dc492e0f0b5";
    hash = "sha256-OlZEmX5TLEg1Vl569RdjCTKEB5dhIrBGR8PH7fRR4OU=";
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
      "--version=branch"
    ];
  };

  meta = {
    description = "Databases used by RetroArch";
    homepage = "https://github.com/libretro/libretro-database";
    platforms = lib.platforms.all;
  };
}
