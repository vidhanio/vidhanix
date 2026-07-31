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
            version = "0-unstable-2026-07-28";

            rev = "65cb1f5f227db45abcd9d2006efe7687a0d9cb72";
            hash = "sha256-MlF6DLkHe2KC+rHHOx6FZTjLMdA3lR/qcSsYqJ3P+tA=";
          };
          Dinothawr = {
            version = "0-unstable-2026-07-28";

            rev = "dde9179cf743838927d67ce3a11ea5904a189d47";
            hash = "sha256-QaWoAyUk+5uGORhAXTN/Z7owqzW8C4gSjrxU9/pfhG4=";
          };
          DirkSimple = {
            version = "0-unstable-2026-07-28";

            owner = "icculus";
            rev = "d5d75f97af34690010166a786ee41e15dd142c15";
            hash = "sha256-W2ljoqPyc2VSjY62BDBcAOwwBJr2zoH60ewPOHMlRJ8=";
          };
          dolphin = {
            version = "2606-unstable-2026-07-31";

            rev = "b78e3b607c22f45719263bd1e001e47589d1c83e";
            hash = "sha256-Hs2Y4fTpPhPH+N+xBXwgoRLlYgo+ZgeWcvYEniGvgi4=";
          };
          ecwolf = {
            version = "0-unstable-2026-07-28";

            rev = "4731f0075d6c225921b40b341b23971e73dd9dfc";
            hash = "sha256-Ex78/SAFbn4ZH6+57hyJl0jPAwAmNSflKLvi72Yj6do=";
          };
          qemu-libretro = {
            version = "0-unstable-2026-07-27";

            owner = "io12";
            rev = "486f2d58930f7f0bea5717b6fc06e7fa3dd109ed";
            hash = "sha256-qERAAHMskesS/jb7ZAzYS+OAR7RzcrGozI+mhiW+quY=";
          };
          xrick-libretro = {
            version = "0-unstable-2026-07-28";

            rev = "fcfde3623a04b4e986548e06d46630fcd0bd1e18";
            hash = "sha256-IkgzXaQErwBt6TOjuDJ4YAZadC4Nvc8/TFUSYRM0DtY=";
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
