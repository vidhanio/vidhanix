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
      python3,
      writeShellScript,
      writeText,

      extraLibraries ? _pkgs: [ ],
      extraEnv ? { },
      extraPkgs ? _pkgs: [ ],
      # microVM RAM ceiling in MiB (balloon-backed, not reserved); `null` = muvm's 80% default, no host headroom on 8GB.
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
          "python3"
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
          "extraEnv"
          "extraPkgs"
        ]
      );

      armClient = stdenvNoCC.mkDerivation {
        pname = "steam-client-arm64";
        version = "1790721607";
        dontUnpack = true;
        client = fetchurl {
          url = "https://client-update.steamstatic.com/bins_linuxarm64_linuxarm64.zip.7e5608630efa476c001328dc0c8543d9fa26f7f1";
          hash = "sha256-I/96wg0SLXxBOhh1HPgI1SrCeP5l2EYI7FYEvzPx3hg=";
        };
        codecs = fetchurl {
          url = "https://client-update.steamstatic.com/codecs_linuxarm64_linuxarm64.zip.b27e1d78cec034a8c73b0ff1bc6acbe3b8586344";
          hash = "sha256-jnel5GBdfHtXbOZKvznP00KuqNZ4Phfy+5HhyPQ1eg8=";
        };
        sdl = fetchurl {
          url = "https://client-update.steamstatic.com/sdl3_linuxarm64_linuxarm64.zip.4fd0ba0265a38cd1bdb0d3e885204051797e8542";
          hash = "sha256-j8wcqsUWHl9iegH1xOOaadkT1lPDA9XDkSQ6O/QiL6o=";
        };
        runtime = fetchurl {
          url = "https://client-update.steamstatic.com/runtime_steamrt_linuxarm64.zip.e9edd7325258d74533681f158780da72e5c1c333";
          hash = "sha256-Bcd/4pXzhcD2qHdYCXb7pRCT0uqfseQmjRTkTPX/oe4=";
        };
        nativeBuildInputs = [ python3 ];
        # Keep SteamRT's container-internal interpreters unchanged.
        dontFixup = true;
        installPhase = ''
          python3 ${./unpack-client.py} $out $client $codecs $sdl $runtime
          chmod +x $out/steamrtarm64/{steam,steamwebhelper,steamwebhelper.sh,gldriverquery,vulkandriverquery,steamsysinfo,reaper,steam_monitor,steamerrorreporter,gameoverlayui,fossilize_replay,streaming_client,vgui_panel_zoo,pv-run.sh,pv-runtime/steam-runtime-steamrt.sh}
        '';
        meta.license = lib.licenses.unfreeRedistributable;
      };

      armLauncher = writeShellScript "steam-arm64" ''
        set -e
        steamroot="$HOME/.local/share/Steam"
        mkdir -p "$steamroot" "$HOME/.steam" "$steamroot/package"
        if [ ! -x "$steamroot/steamrtarm64/steam" ] \
          || [ ! -e "$steamroot/steamrtarm64/libSDL3.so.0" ] \
          || [ ! -e "$steamroot/steamrtarm64/libavcodec.so" ] \
          || [ ! -e "$steamroot/steamrtarm64/pv-runtime/steam-runtime-steamrt/VERSIONS.txt" ]; then
          mkdir -p "$steamroot/steamrtarm64"
          cp -an ${armClient}/steamrtarm64/. "$steamroot/steamrtarm64/"
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
        export LD_LIBRARY_PATH="$steamroot/steamrtarm64''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
        restarts=0
        while true; do
          if "$steamroot/steamrtarm64/steam" -noverifyfiles "$@"; then
            exit 0
          else
            status=$?
          fi
          if [ "$status" -ne 42 ]; then
            exit "$status"
          fi
          restarts=$((restarts + 1))
          if [ "$restarts" -gt 5 ]; then
            echo "Steam requested too many consecutive restarts" >&2
            exit 42
          fi
        done
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
          set -a
          ${lib.toShellVars extraEnv}
          set +a
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

      # steam's tray clients only accept `EXTERNAL` auth on unix sockets.
      # front the host session bus (see `hostBusScript`) with a guest-local socket
      # over this vsock port. muvm maps each port to a host socket under
      # `$XDG_RUNTIME_DIR/krun/socket`.
      vsockPort = 50001;
      guestBusScript = writeShellScript "muvm-steam-guest-bus.sh" ''
        nohup ${lib.getExe socat} UNIX-LISTEN:/run/user/1000/muvm-bus,fork,reuseaddr VSOCK-CONNECT:2:${toString vsockPort} >/dev/null 2>&1 &
      '';

      # host half of the D-Bus bridge, owned by the wrapper: forward the krun
      # vsock socket to the session bus, then run the launcher (muvm + guest
      # flags) passed as `$1`. concurrent instances share the first listener.
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
        description = "ARM64 Steam beta client with codecs and runtime in muvm for Apple Silicon";
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
