let
  pkg =
    {
      config,
      lib,
      makeWrapper,
      muvm,
      path,
      socat,
      writeShellScript,
      symlinkJoin,
      writeText,

      # microVM RAM ceiling in MiB (balloon-backed, not reserved); null = muvm's 80% default, no host headroom on 8GB.
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
          "makeWrapper"
          "muvm"
          "path"
          "socat"
          "writeShellScript"
          "writeText"
          "symlinkJoin"
          "memoryMiB"

          # both are built from host config: they'd leak aarch64 libs into the x86_64 FHS env; the guest takes drivers from /run/opengl-driver and fonts from the host.
          "extraLibraries"
          "extraPkgs"
        ]
      );

      initScript = writeShellScript "muvm-steam-init.sh" ''
        ln -snf ${mesa} /run/opengl-driver
        ln -snf ${mesa32} /run/opengl-driver-32
      '';

      # steam's tray clients only accept EXTERNAL auth on unix sockets, so the
      # host session bus (see hostBusScript) is fronted with a guest-local
      # socket over this vsock port; muvm maps each such port to a host socket
      # under $XDG_RUNTIME_DIR/krun/socket.
      vsockPort = 50001;
      guestBusScript = writeShellScript "muvm-steam-guest-bus.sh" ''
        nohup ${lib.getExe socat} UNIX-LISTEN:/run/user/1000/muvm-bus,fork,reuseaddr VSOCK-CONNECT:2:${toString vsockPort} >/dev/null 2>&1 &
      '';

      # host half of the D-Bus bridge, owned by the wrapper: forward the krun
      # vsock socket to the session bus, then run the launcher (muvm + guest
      # flags) passed as $1. concurrent instances share the first listener.
      hostBusScript = writeShellScript "muvm-steam-host-bus.sh" ''
        set -e
        launcher=$1
        shift
        host_bus="$XDG_RUNTIME_DIR/krun/socket/port-${toString vsockPort}"
        rm -f "$host_bus"
        ${lib.getExe socat} UNIX-LISTEN:"$host_bus",fork,reuseaddr UNIX-CONNECT:"$XDG_RUNTIME_DIR/bus" &
        bridge_pid=$!
        cleanup() {
          if kill -0 "$bridge_pid" 2>/dev/null; then
            kill "$bridge_pid" 2>/dev/null || true
            rm -f "$host_bus"
          fi
        }
        trap cleanup EXIT
        "$launcher" "$@"
      '';

      pulse-conf = writeText "pulse.conf" ''
        enable-shm=no
      '';

      muvmFlags = [
        "-x ${initScript}"
        "-X ${guestBusScript}"
        "-e PULSE_CLIENTCONFIG=${pulse-conf}"
        "-e DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/muvm-bus"
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

              makeWrapper ${lib.getExe muvm} $out/bin/.${program}-launcher \
                --add-flags "${lib.concatStringsSep " " muvmFlags} $out/bin/.${program}-wrapped"

              makeWrapper ${hostBusScript} $out/bin/${program} \
                --add-flags "$out/bin/.${program}-launcher"
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
        muvm-steam = pkgs.callPackage pkg { };
      };
    };
}
