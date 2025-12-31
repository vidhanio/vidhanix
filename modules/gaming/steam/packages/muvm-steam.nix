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
          name = pkg.meta.mainProgram;
        in
        ''
          mkdir -p $out
          cp -r ${pkg}/* $out/
          chmod -R u+w $out
          mv $out/bin/${name} $out/bin/.${name}-wrapped

          echo "#! ${stdenvNoCC.shell} -e" > $out/bin/${name}
          echo \
            ${lib.getExe muvm} \
              -x ${initScript} \
              -e PULSE_CLIENTCONFIG=${pulse-conf} \
              \""$out/bin/.${name}-wrapped"\" '"$@"' \
            >> $out/bin/${name}
          chmod +x $out/bin/${name}
        '';
    in
    stdenvNoCC.mkDerivation {
      pname = "muvm-${steam.pname}";
      inherit (steam) version;

      buildCommand = wrapMuvm steam;

      passthru.run = stdenvNoCC.mkDerivation {
        name = "muvm-${steam.run.name}";

        buildCommand = wrapMuvm steam.run;

        inherit (steam.run) meta;
      };

      inherit (steam) meta;
    };
in
{
  perSystem =
    { self', pkgs, ... }:
    {
      packages.muvm-steam = pkgs.callPackage pkg { };
    };
}
