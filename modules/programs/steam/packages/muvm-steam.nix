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

      # muvm forwards no D-Bus session bus into the guest, and AF_UNIX sockets
      # don't cross virtiofs, so Steam can't register its tray icon. The
      # muvm-dbus-bridge user service (see the steam module) exposes the host
      # session bus on loopback TCP; passt routes guest traffic to the host's
      # default gateway over to loopback, so the guest points at
      # tcp:host=<host default gateway>. Keep the port in sync with the service.
      dbusBridgePort = 49001;
      dbusBridgeEnv = writeShellScript "muvm-steam-dbus-env.sh" ''
        # /proc/net/route encodes the gateway in hex, little-endian
        gw=$(awk '$2 == "00000000" { g = $3; exit } END { if (g != "") printf "%d.%d.%d.%d", strtonum("0x" substr(g, 7, 2)), strtonum("0x" substr(g, 5, 2)), strtonum("0x" substr(g, 3, 2)), strtonum("0x" substr(g, 1, 2)) }' /proc/net/route)
        if [ -n "$gw" ]; then
          export DBUS_SESSION_BUS_ADDRESS="tcp:host=$gw,port=${toString dbusBridgePort}"
        else
          # no default route: keep muvm's -e flag satisfiable, same as before
          export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/muvm-host/run/user/1000/bus
        fi
      '';

      pulse-conf = writeText "pulse.conf" ''
        enable-shm=no
      '';

      muvmFlags = [
        "-x ${initScript}"
        "-e PULSE_CLIENTCONFIG=${pulse-conf}"
        "-e DBUS_SESSION_BUS_ADDRESS"
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
                --run ". ${dbusBridgeEnv}" \
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
      ...
    }:
    {
      packages = {
        # TODO: drop once https://github.com/NixOS/nixpkgs/pull/554106 lands (fex 2605 -> 2608)
        muvm-steam =
          (pkgs.extend (
            _: prev: {
              fex = prev.fex.overrideAttrs (old: {
                version = "2608";
                src = old.src.override {
                  hash = "sha256-2NdkQpzqDkM/fEW8QYS05KU3JPJeLw4gliryqdOJ3vE=";
                };
                postInstall = (old.postInstall or "") + ''
                  ln -s FEX $out/bin/FEXInterpreter
                '';
              });
            }
          )).callPackage
            pkg
            { };
      };
    };
}
