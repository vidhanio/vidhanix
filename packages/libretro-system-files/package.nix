{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  which,
  bash,
  libretro,
  p7zip,
  zip,
  unzip,
  writeScript,
  nix-update,
}:
let
  packagedRepos = with libretro; {
    blueMSX-libretro = bluemsx;
    dolphin = dolphin;
    FBNeo = fbneo;
    mame2003-plus-libretro = mame2003-plus;
    mame2003-libretro = mame2003;
    nxengine-libretro = nxengine;
    ps2 = pcsx2;
    ppsspp = ppsspp;
    libretro-prboom = prboom;
    scummvm = scummvm;
  };

  customRepos =
    let
      mkCustomRepo =
        repo:
        {
          owner ? "libretro",
          version,
          rev,
          hash,
        }:
        stdenvNoCC.mkDerivation {
          pname = repo;
          inherit version;

          src = fetchFromGitHub {
            inherit
              owner
              repo
              rev
              hash
              ;
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
    lib.mapAttrs mkCustomRepo {
      cannonball = {
        version = "0.3-unstable-2024-10-21";

        rev = "5137a791d229a5b9c7c089cf1edcce4db3c57d64";
        hash = "sha256-jp58bKr8bisJOXCz9M+bmA06p8bPJw9Bn9eJJy4aGEg=";
      };
      Dinothawr = {
        version = "0-unstable-2024-10-21";

        rev = "e57e780a963372b89736620d7e3b8608190f7581";
        hash = "sha256-Gg7yEiHisMgC5+yQ0dxyf4x0QOTDqpBlI8+E3gtMLHI=";
      };
      DirkSimple = {
        version = "0-unstable-2024-12-03";

        owner = "icculus";
        rev = "a5b0ebca483cd10babe930a57e75b0e6094686fb";
        hash = "sha256-ZaQMWVgKP1D+biJaNrLqqtLqMfRp1FovlI6AEBlCO5Y=";
      };
      ecwolf = {
        version = "0-unstable-2025-04-16";

        rev = "c57ad894d5942740b4896511e8554c9a776b04a6";
        hash = "sha256-KOZfm1MpLAng9YzydU7YeJfDN1lqkX78gz5tzRe0aOE=";
      };
      qemu-libretro = {
        version = "0-unstable-2025-08-19";

        owner = "io12";
        rev = "86ea49ba18309ea003bbf212f5eace20bedbb6f9";
        hash = "sha256-hBEwJE8x0+wsfvMo0ANWs+lItBRBradZ1F6blY1wzQ4=";
      };
      xrick-libretro = {
        version = "0-unstable-2025-01-05";

        rev = "476a9a637a6d2afa3f9f6b202bb98b522a4e95d1";
        hash = "sha256-rBGY/BuJZZc2KrxnC7e6YgjOP/eCBSvO8IS39re9+vc=";
      };
    };
in
stdenvNoCC.mkDerivation {
  pname = "libretro-system-files";
  version = "0-unstable-2024-12-26";

  src = fetchFromGitHub {
    owner = "libretro";
    repo = "libretro-system-files";
    rev = "c9bd84a44c017f7cdf96dd2ab8a064d425d239c6";
    hash = "sha256-7dFJ43nzdUypRNTxK4Vif0WFrpMIs6oy+QcU1PDUtOI=";
  };

  patches = [ ./no-git.patch ];

  postUnpack = lib.concatLines (
    lib.mapAttrsToList (name: repo: ''
      cp -r ${repo.src} $sourceRoot/src_repos/${name}
      chmod -R u+w $sourceRoot/src_repos/${name}
    '') (packagedRepos // customRepos)
  );

  postPatch = ''
    substituteInPlace ./make.sh ./src_repos/scummvm/backends/platform/libretro/scripts/bundle_datafiles.sh \
      --replace-fail "/bin/bash" "${lib.getExe bash}"
  '';

  nativeBuildInputs = [
    which
    p7zip
    zip
    unzip
  ];

  buildPhase = ''
    runHook preBuild

    ./make.sh

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/libretro/system
    for file in out/*; do
      unzip -o "$file" -d $out/share/libretro/system/
    done

    runHook postInstall
  '';

  passthru = {
    updateScript =
      let
        nix-update-latest = "${lib.getExe nix-update} --flake --version=branch";
      in
      writeScript "update.sh" ''
        ${nix-update-latest}
        ${lib.concatMapStrings (name: ''
          ${nix-update-latest} "''${UPDATE_NIX_ATTR_PATH:?}".repos.${name}
        '') (lib.attrNames customRepos)}
      '';

    repos = customRepos;
  };

  meta = {
    description = "Databases used by RetroArch";
    homepage = "https://github.com/libretro/libretro-database";
    license = lib.licenses.cc-by-sa-40;
    platforms = lib.platforms.all;
  };
}
