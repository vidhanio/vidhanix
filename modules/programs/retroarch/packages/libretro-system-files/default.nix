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
            version = "0-unstable-2026-07-21";

            rev = "65cb1f5f227db45abcd9d2006efe7687a0d9cb72";
            hash = "sha256-MlF6DLkHe2KC+rHHOx6FZTjLMdA3lR/qcSsYqJ3P+tA=";
          };
          Dinothawr = {
            version = "0-unstable-2026-07-21";

            rev = "e608bc507d4e76940be4af3d74b5fecb2dfa26a6";
            hash = "sha256-RJJtiNwHEACqtCgagxRYtYP9WtV+3Fl5hCs1Mdink+A=";
          };
          DirkSimple = {
            version = "0-unstable-2026-06-11";

            owner = "icculus";
            rev = "e13ee21dfcc3b68a23a8104ae8862281e0f548ff";
            hash = "sha256-yjCmKerjzt+TTMRfvsqpfwuNz8Jz3tyaOyKwzYnM0VQ=";
          };
          dolphin = {
            version = "2606-unstable-2026-07-26";

            rev = "f76197ad8aeb87f9bb7a19d4d17edfced92aa251";
            hash = "sha256-lu8fEPJTIWPG/WYUc/biYH2RfzgLSd7v0LLZeEsggoY=";
          };
          ecwolf = {
            version = "0-unstable-2026-07-21";

            rev = "4731f0075d6c225921b40b341b23971e73dd9dfc";
            hash = "sha256-Ex78/SAFbn4ZH6+57hyJl0jPAwAmNSflKLvi72Yj6do=";
          };
          qemu-libretro = {
            version = "0-unstable-2025-08-19";

            owner = "io12";
            rev = "86ea49ba18309ea003bbf212f5eace20bedbb6f9";
            hash = "sha256-hBEwJE8x0+wsfvMo0ANWs+lItBRBradZ1F6blY1wzQ4=";
          };
          xrick-libretro = {
            version = "0-unstable-2026-07-21";

            rev = "35de6ac478c9998bcf79b6de2aca8dc371cd5ab1";
            hash = "sha256-NCgDcLZ5pYDn6msFk5wnjtf5MWd5Fq+gePUb0W9ponI=";
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
