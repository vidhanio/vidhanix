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
            version = "0-unstable-2026-04-20";

            rev = "ae1bba5bb842a234e0233824e118fe39a89505a0";
            hash = "sha256-4GCZeKJ8s6DPz3ALz7BU6PsO1yHQvsCjbY9m3OknLzM=";
          };
          Dinothawr = {
            version = "0-unstable-2026-04-20";

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
            version = "2606-unstable-2026-07-19";

            rev = "c546e92fae92877f7f60b74d56c68b46cc0b596e";
            hash = "sha256-93CHOpR/bxF3p+t5qhFRTbT/RyZOmnHjEoxsF/ozenY=";
          };
          ecwolf = {
            version = "0-unstable-2026-04-20";

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
            version = "0-unstable-2026-04-20";

            rev = "9fcdd91d1835a2bb66f87af9a3986b6f19aa2390";
            hash = "sha256-gxmP/WKLeN3mSw91B52oqx2xWvMPHdyDvNd6ffuYmag=";
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
