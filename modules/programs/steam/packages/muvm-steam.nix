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

      # MicroVM RAM ceiling in MiB (balloon-backed, not reserved); null = muvm's 80% default, no host headroom on 8GB.
      memoryMiB ? null,
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
          "memoryMiB"

          # Both are built from host config: they'd leak aarch64 libs into the x86_64 FHS env; the guest takes drivers from /run/opengl-driver and fonts from the host.
          "extraLibraries"
          "extraPkgs"
        ]
      );

      initScript = writeShellScript "muvm-steam-init.sh" ''
        ln -snf ${mesa} /run/opengl-driver
        ln -snf ${mesa32} /run/opengl-driver-32
      '';

      pulse-conf = writeText "pulse.conf" ''
        enable-shm=no
      '';

      muvmFlags = [
        "-x ${initScript}"
        "-e PULSE_CLIENTCONFIG=${pulse-conf}"
      ]
      ++ lib.optional (memoryMiB != null) "--mem=${toString memoryMiB}";

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
                --add-flags "${lib.concatStringsSep " " muvmFlags} $out/bin/.${program}-wrapped"
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
    {
      pkgs,
      lib,
      system,
      ...
    }:
    {
      # aarch64-only (Apple Silicon); exposing it on x86_64-linux fails
      # `nix flake check` against meta.platforms.
      packages = lib.mkIf (system == "aarch64-linux") {
        muvm-steam = pkgs.callPackage pkg { };
      };
    };
}
