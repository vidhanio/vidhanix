let
  pkg =
    {
      stdenvNoCC,
      config,
      lib,
      muvm,
      path,
      writeShellScript,
      writeText,
      ...
    }@args:
    let
      pkgs-x86_64 = import path {
        system = "x86_64-linux";
        inherit config;
      };

      inherit (pkgs-x86_64) mesa;
      mesa32 = pkgs-x86_64.pkgsi686Linux.mesa;
      steam = pkgs-x86_64.steam.override (
        lib.removeAttrs args [
          "stdenvNoCC"
          "config"
          "lib"
          "muvm"
          "path"
          "writeShellScript"
          "writeText"
          "extraLibraries"
        ]
      );

      initScript = writeShellScript "muvm-steam-init.sh" ''
        ln -snf ${mesa} /run/opengl-driver
        ln -snf ${mesa32} /run/opengl-driver-32
      '';

      pulse-conf = writeText "pulse.conf" ''
        enable-shm=no
      '';

      wrapMuvm =
        pkg:
        let
          program = pkg.meta.mainProgram;
        in
        ''
          mkdir -p $out
          cp -r ${pkg}/* $out/
          chmod -R u+w $out
          mv $out/bin/${program} $out/bin/.${program}-wrapped

          echo "#! ${stdenvNoCC.shell} -e" > $out/bin/${program}
          echo \
            ${lib.getExe muvm} \
              -x ${initScript} \
              -e PULSE_CLIENTCONFIG=${pulse-conf} \
              \""$out/bin/.${program}-wrapped"\" '"$@"' \
            >> $out/bin/${program}
          chmod +x $out/bin/${program}
        '';
    in
    stdenvNoCC.mkDerivation {
      pname = "muvm-${steam.pname}";
      inherit (steam) version;

      src = steam;

      buildCommand = wrapMuvm steam;

      passthru.run = stdenvNoCC.mkDerivation {
        name = "muvm-${steam.run.name}";

        buildCommand = wrapMuvm steam.run;

        inherit (steam.run) meta;
      };

      meta = steam.meta // {
        description = "The Steam client, wrapped to run in muvm for Apple Silicon support";
        platforms = [ "aarch64-linux" ];
      };
    };
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages.muvm-steam =
        let
          # FIXME: https://github.com/NixOS/nixpkgs/pull/485411
          libkrunOverlay = final: prev: {
            libkrun = prev.libkrun.overrideAttrs (
              finalAttrs: prevAttrs: {
                version = "1.17.0";

                src = prevAttrs.src.override {
                  hash = "sha256-6HBSL5Zu29sDoEbZeQ6AsNIXUcqXVVGMk0AR2X6v1yU=";
                };

                cargoDeps = final.rustPlatform.fetchCargoVendor {
                  inherit (finalAttrs) src;
                  hash = "sha256-UIzbtBJH6aivoIxko1Wxdod/jUN44pERX9Hd+v7TC3Q=";
                };
              }
            );

            libkrunfw = prev.libkrunfw.overrideAttrs (old: {
              version = "5.1.0";
              src = old.src.override {
                hash = "sha256-x9HQP+EqCteoCq2Sl/TQcfdzQC5iuE4gaSKe7tN5dAA=";
              };
              kernelSrc = final.fetchurl {
                url = "mirror://kernel/linux/kernel/v6.x/linux-6.12.62.tar.xz";
                hash = "sha256-E+LGhayPq13Zkt0QVzJVTa5RSu81DCqMdBjnt062LBM=";
              };
            });
          };
        in
        (pkgs.extend libkrunOverlay).callPackage pkg { };
    };
}
