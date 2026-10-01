let
  pkg =
    {
      buildFHSEnv,
      config,
      fetchurl,
      lib,
      makeWrapper,
      muvm,
      path,
      socat,
      stdenvNoCC,
      symlinkJoin,
      unzip,
      writeShellScript,
      writeText,

      extraLibraries ? _pkgs: [ ],
      extraPkgs ? _pkgs: [ ],
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
      steamX86 = pkgs-x86_64.steam.override (
        lib.removeAttrs args [
          "buildFHSEnv"
          "stdenvNoCC"
          "fetchurl"
          "unzip"
          "pkgs"
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
          "extraLibraries"
          "extraPkgs"
        ]
      );

      armClient = stdenvNoCC.mkDerivation {
        pname = "steam-client-arm64";
        version = "1790721607";
        src = fetchurl {
          url = "https://client-update.steamstatic.com/bins_linuxarm64_linuxarm64.zip.7e5608630efa476c001328dc0c8543d9fa26f7f1";
          hash = "sha256-I/96wg0SLXxBOhh1HPgI1SrCeP5l2EYI7FYEvzPx3hg=";
        };
        nativeBuildInputs = [ unzip ];
        unpackPhase = "unzip -q $src";
        installPhase = ''
          mkdir -p $out
          cp -a steamrtarm64 $out/
          chmod -R u+rwX $out/steamrtarm64
          chmod +x $out/steamrtarm64/{steam,steamwebhelper,steamwebhelper.sh,gldriverquery,vulkandriverquery,steamsysinfo,reaper,steam_monitor,steamerrorreporter,gameoverlayui,fossilize_replay,streaming_client,vgui_panel_zoo}
        '';
        meta.license = lib.licenses.unfreeRedistributable;
      };

      armLauncher = writeShellScript "steam-arm64" ''
        set -e
        steamroot="$HOME/.local/share/Steam"
        mkdir -p "$steamroot" "$HOME/.steam" "$steamroot/package"
        if [ ! -x "$steamroot/steamrtarm64/steam" ]; then
          mkdir -p "$steamroot/steamrtarm64"
          cp -a ${armClient}/steamrtarm64/. "$steamroot/steamrtarm64/"
          chmod -R u+rwX "$steamroot/steamrtarm64"
        fi
        if [ -d "$steamroot/steamrt64" ] && [ ! -L "$steamroot/steamrt64" ]; then
          if [ -e "$steamroot/steamrt64-x86" ]; then
            echo "Cannot migrate steamrt64: steamrt64-x86 already exists" >&2
            exit 1
          fi
          mv "$steamroot/steamrt64" "$steamroot/steamrt64-x86"
        fi
        ln -sfn steamrtarm64 "$steamroot/steamrt64"
        ln -sfn "$steamroot" "$HOME/.steam/steam"
        ln -sfn "$steamroot" "$HOME/.steam/root"
        ln -sfn "$steamroot/linuxarm64" "$HOME/.steam/sdkarm64"
        printf 'publicbeta\n' > "$steamroot/package/beta"
        touch "$steamroot/.steam-enable-steamrt64-client"
        exec "$steamroot/steamrtarm64/steam" -noverifyfiles "$@"
      '';

      steam = buildFHSEnv {
        pname = "steam";
        inherit (armClient) version;
        runScript = armLauncher;
        includeClosures = true;
        targetPkgs =
          p:
          with p;
          [
            bash
            coreutils
            file
            glibc.bin
            libx11
            lsb-release
            pciutils
            usbutils
            xdg-utils
            xz
            zenity
            glibc
            libxcrypt
            libGL
            libdrm
            libgbm
            udev
            libudev0-shim
            libva
            vulkan-loader
            networkmanager
            libcap
          ]
          ++ extraPkgs p
          ++ extraLibraries p;
        profile = ''
          unset GIO_EXTRA_MODULES
          export SDL_JOYSTICK_DISABLE_UDEV=1
          export GTK_IM_MODULE=xim
          export LIBGL_DRIVERS_PATH=/run/opengl-driver/lib/dri:/run/opengl-driver-32/lib/dri
          export __EGL_VENDOR_LIBRARY_DIRS=/run/opengl-driver/share/glvnd/egl_vendor.d:/run/opengl-driver-32/share/glvnd/egl_vendor.d
          export LIBVA_DRIVERS_PATH=/run/opengl-driver/lib/dri:/run/opengl-driver-32/lib/dri
          export VDPAU_DRIVER_PATH=/run/opengl-driver/lib/vdpau:/run/opengl-driver-32/lib/vdpau
        '';
        extraInstallCommands = ''
          ln -s ${steamX86}/share $out/share
        '';
        passthru.run = steamX86.run;
        meta = steamX86.meta // {
          description = "Native ARM64 Steam beta client in an FHS environment";
          platforms = [ "aarch64-linux" ];
        };
      };

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
      passthru.run = wrapMuvm steamX86.run { };
      meta = steam.meta // {
        description = "Native ARM64 Steam beta client in muvm for Apple Silicon";
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
