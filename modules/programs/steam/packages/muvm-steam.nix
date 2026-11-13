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
      writeShellScript,
      unzip,
      writeText,

      extraLibraries ? _pkgs: [ ],
      extraEnv ? { },
      extraPkgs ? _pkgs: [ ],
    }:
    let
      pkgs-x86_64 = import path {
        system = "x86_64-linux";
        inherit config;
      };

      inherit (pkgs-x86_64) mesa;
      mesa32 = pkgs-x86_64.pkgsi686Linux.mesa;
      steamX86 = pkgs-x86_64.steam;

      armClient = stdenvNoCC.mkDerivation {
        pname = "steam-client-arm64";
        version = "1790721607";
        src = fetchurl {
          url = "https://client-update.steamstatic.com/bins_linuxarm64_linuxarm64.zip.7e5608630efa476c001328dc0c8543d9fa26f7f1";
          hash = "sha256-I/96wg0SLXxBOhh1HPgI1SrCeP5l2EYI7FYEvzPx3hg=";
        };
        nativeBuildInputs = [ unzip ];
        dontUnpack = true;
        dontFixup = true;
        installPhase = ''
          mkdir -p "$out"
          unzip -q "$src" -d "$out"
          chmod +x "$out/steamrtarm64/steam"
        '';
        meta.license = lib.licenses.unfreeRedistributable;
      };

      armLauncher = writeShellScript "steam-arm64" ''
        set -e
        steamroot="$HOME/.local/share/Steam"
        mkdir -p "$steamroot" "$HOME/.steam" "$steamroot/package"
        # Seed only the client; Steam downloads and maintains its own components.
        if [ ! -x "$steamroot/steamrtarm64/steam" ]; then
          cp -r ${armClient}/steamrtarm64 "$steamroot/"
          chmod -R u+w "$steamroot/steamrtarm64"
        fi
        ln -sfn "$steamroot" "$HOME/.steam/steam"
        ln -sfn "$steamroot" "$HOME/.steam/root"
        ln -sfn "$steamroot/linuxarm64" "$HOME/.steam/sdkarm64"
        printf 'publicbeta\n' > "$steamroot/package/beta"
        touch "$steamroot/.steam-enable-steamrt64-client"
        export LD_LIBRARY_PATH="$steamroot/steamrtarm64''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
        status=42
        while [ "$status" -eq 42 ]; do
          status=0
          "$steamroot/steamrtarm64/steam" "$@" || status=$?
        done
        exit "$status"
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
            sdl3
            coreutils
            file
            glibc.bin
            gtk2 # Required by the ARM64 client's steamui.so.
            ibus # Required by steamwebhelper.
            nss
            nspr
            libx11
            lsb-release
            lsof
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

      # muvm maps vsock ports 50000-50199 to `$XDG_RUNTIME_DIR/krun/socket/port-N`
      # and allocates its own from the bottom.
      vsockPort = toString 50199;
      guestBus = "/run/user/1000/bus";
      guestBusScript = writeShellScript "muvm-steam-guest-bus.sh" ''
        nohup ${lib.getExe socat} UNIX-LISTEN:${guestBus},fork VSOCK-CONNECT:2:${vsockPort} >/dev/null 2>&1 &
      '';

      pulse-conf = writeText "pulse.conf" ''
        enable-shm=no
      '';

      muvmFlags = [
        "-x ${initScript}"
        "-X ${guestBusScript}"
        "-e PULSE_CLIENTCONFIG=${pulse-conf}"
        "-e DBUS_SESSION_BUS_ADDRESS=unix:path=${guestBus}"
      ];

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
                --run 'mkdir -p "$XDG_RUNTIME_DIR/krun/socket"' \
                --run 'ln -sfn "$XDG_RUNTIME_DIR/bus" "$XDG_RUNTIME_DIR/krun/socket/port-${vsockPort}"' \
                --add-flags "${lib.concatStringsSep " " muvmFlags} $out/bin/.${program}-wrapped"
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
