let
  pkg =
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
      _experimental-update-script-combinators,
      nix-update-script,
    }:
    let
      packagedRepos = with libretro; {
        blueMSX-libretro = bluemsx;
        inherit dolphin;
        FBNeo = fbneo;
        mame2003-plus-libretro = mame2003-plus;
        mame2003-libretro = mame2003;
        nxengine-libretro = nxengine;
        ps2 = pcsx2;
        inherit ppsspp;
        libretro-prboom = prboom;
        inherit scummvm;
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
            version = "0-unstable-2025-12-12";

            rev = "d66dde551be8e68e47c05e88838b4f1c6b114c99";
            hash = "sha256-wJj1wzCnMc1/KIOQ1mi3JyaxWtVIkquYgzgz/W6XOVs=";
          };
          DirkSimple = {
            version = "0-unstable-2026-02-09";

            owner = "icculus";
            rev = "5aea3e2951ed641908a7bd2ca09019614003b5e3";
            hash = "sha256-jVARf0qOtNiCPhAqj4debgJ9Bnl9A7Zmc+bjZNGdcBY=";
          };
          ecwolf = {
            version = "0-unstable-2026-02-11";

            rev = "15c1aa3114b2b9cdb1baec0a6467b2b868371446";
            hash = "sha256-zOrZ3zBylhgucOvB9RgIlRFdiiwk3zMkHC7AvVJwiWI=";
          };
          qemu-libretro = {
            version = "0-unstable-2025-08-19";

            owner = "io12";
            rev = "86ea49ba18309ea003bbf212f5eace20bedbb6f9";
            hash = "sha256-hBEwJE8x0+wsfvMo0ANWs+lItBRBradZ1F6blY1wzQ4=";
          };
          xrick-libretro = {
            version = "0-unstable-2025-12-30";

            rev = "34e4c3fc8a679d0209debc3738dc7264d3112a03";
            hash = "sha256-IPDb1OTapOJaELmFbz6UoOQ8/hnBF0k0PSFivkJ7KtY=";
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
        repos = customRepos;

        updateScript = _experimental-update-script-combinators.sequence (
          [
            (nix-update-script {
              extraArgs = [
                "--flake"
                "--version=branch"
              ];
            })
          ]
          ++ map (
            name:
            (nix-update-script {
              extraArgs = [
                "--flake"
                "--version=branch"
                "libretro-system-files.repos.${name}"
              ];
            })
          ) (lib.attrNames customRepos)
        );
      };

      meta = {
        description = "Auxiliary libretro core system files provided through the online updater";
        homepage = "https://github.com/libretro/libretro-system-files";
        license = lib.licenses.cc-by-sa-40;
        platforms = lib.platforms.all;
      };
    };
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages.libretro-system-files = pkgs.callPackage pkg { };
    };
}
