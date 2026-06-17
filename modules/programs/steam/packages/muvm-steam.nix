let
  pkg =
    {
      config,
      lib,
      muvm,
      path,
      writeShellScript,
      symlinkJoin,
      writeText,
      makeWrapper,
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
          "symlinkJoin"
          "makeWrapper"

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
        pkg: extraAttrs:
        let
          program = pkg.meta.mainProgram;
        in
        symlinkJoin (
          {
            inherit (pkg) pname version;

            paths = [ pkg ];

            nativeBuildInputs = [ makeWrapper ];

            postBuild = ''
              mv $out/bin/${program} $out/bin/.${program}-wrapped

              makeWrapper ${lib.getExe muvm} $out/bin/${program} \
                --argv0 steam \
                --add-flags "-x ${initScript} -e PULSE_CLIENTCONFIG=${pulse-conf} $out/bin/.${program}-wrapped"
            '';
            inherit (pkg) meta;
          }
          // extraAttrs
        );
    in
    wrapMuvm steam {
      name = "muvm-${steam.name}";
      passthru.run = wrapMuvm steam.run { };
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
      packages.muvm-steam = pkgs.callPackage pkg { };
    };
}
