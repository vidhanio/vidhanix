let
  pkg =
    {
      lib,
      libretro,
      stdenvNoCC,
      bash,
      which,
      p7zip,
      zip,
      unzip,

      libretro-system-files-src,
      cannonball,
      dinothawr,
      dirksimple,
      ecwolf,
      qemu-libretro,
      xrick-libretro,
    }:
    let
      packagedRepos = lib.mapAttrs (_: repo: repo.src) (
        with libretro;
        {
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
        }
      );

      inputRepos = {
        inherit cannonball;
        Dinothawr = dinothawr;
        DirkSimple = dirksimple;
        inherit ecwolf;
        inherit qemu-libretro;
        inherit xrick-libretro;
      };
    in
    stdenvNoCC.mkDerivation {
      name = "libretro-system-files";

      src = libretro-system-files-src;

      patches = [ ./no-git.patch ];

      postUnpack = lib.concatLines (
        lib.mapAttrsToList (name: repo: ''
          cp -r ${repo} $sourceRoot/src_repos/${name}
          chmod -R u+w $sourceRoot/src_repos/${name}
        '') (packagedRepos // inputRepos)
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

      meta = {
        description = "Databases used by RetroArch";
        homepage = "https://github.com/libretro/libretro-database";
        license = lib.licenses.cc-by-sa-40;
        platforms = lib.platforms.all;
      };
    };
in
{
  inputs,
  ...
}:
{
  perSystem =
    {
      pkgs,
      self',
      ...
    }:
    {
      packages.libretro-system-files = pkgs.callPackage pkg {
        inherit (inputs)
          libretro-system-files-src
          cannonball
          dinothawr
          dirksimple
          ecwolf
          qemu-libretro
          xrick-libretro
          ;
      };
    };
}
