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
          "makeWrapper"
          "muvm"
          "path"
          "socat"
          "writeShellScript"
          "writeText"
          "symlinkJoin"
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

      # Steam's tray clients (libappindicator, launcher-service) only accept
      # EXTERNAL auth on unix sockets, so a tcp: session-bus address gets
      # rejected. Bridge the host session bus to a unix socket inside the guest:
      # this script (run via muvm -X) fronts the host half with a guest-local
      # socket, and hostBridge (in the wrapper) listens on the matching krun
      # dynamic vsock port, which muvm maps to $XDG_RUNTIME_DIR/krun/socket for
      # every VM. Keep both halves on the same port.
      vsockPort = 50001;
      dbusBridgeScript = writeShellScript "muvm-steam-dbus-bridge.sh" ''
        nohup ${lib.getExe socat} UNIX-LISTEN:/run/user/1000/muvm-bus,fork,reuseaddr VSOCK-CONNECT:2:${toString vsockPort} >/dev/null 2>&1 &
      '';

      # Host half of the D-Bus bridge, owned by the wrapper: listen on the
      # krun dynamic vsock socket and forward to the session bus. If another
      # Steam instance already serves it, let that one win (shared listener).
      # The launching script (muvm + guest flags) is passed as the first
      # argument by wrapMuvm.
      bridgeScript = writeShellScript "muvm-steam-dbus-bridge.sh" ''
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
        "-X ${dbusBridgeScript}"
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

              makeWrapper ${bridgeScript} $out/bin/${program} \
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
