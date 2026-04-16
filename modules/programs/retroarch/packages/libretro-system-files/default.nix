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
            version = "0.3-unstable-2026-03-31";

            rev = "9785958a9ba919e1af8864a69ccda81a4b321f4c";
            hash = "sha256-mrzTzV57goq4pml92D2JcLvcE+63pWQzTTidEYfecaM=";
          };
          Dinothawr = {
            version = "0-unstable-2026-04-10";

            rev = "121968c0341c573ab6e5715466c017d22ebd904c";
            hash = "sha256-KujDt2XxDl9+fuPkyHvtw5p7cDyWrwe4GKbA9Ez2yCw=";
          };
          DirkSimple = {
            version = "0-unstable-2026-02-09";

            owner = "icculus";
            rev = "5aea3e2951ed641908a7bd2ca09019614003b5e3";
            hash = "sha256-jVARf0qOtNiCPhAqj4debgJ9Bnl9A7Zmc+bjZNGdcBY=";
          };
          dolphin = {
            version = "5.0-unstable-2026-04-08";

            rev = "0cd3bb89c29535db9b7552fc86871867ccf5b471";
            hash = "sha256-nL1btOCav0HetOXWiLjdJU5aL7/j/9lvWucE5Rxjmp0=";
          };
          ecwolf = {
            version = "0-unstable-2026-04-10";

            rev = "d0a914fb6db525325560a69c14591358b791ddae";
            hash = "sha256-7A5ruzG5GK3jqlH0cR4YXGwlJfTr2XNNaeBU2ueZRZ4=";
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
      version = "0-unstable-2026-02-27";

      src = fetchFromGitHub {
        owner = "libretro";
        repo = "libretro-system-files";
        rev = "c38fc01dd08fdb2278d8e549028b9b2d3afbf032";
        hash = "sha256-pSCpObE9vnUbMqllNM8OViJILjJwzO+7csjFXBNQhDk=";
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
