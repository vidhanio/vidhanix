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
      pkgs,
      socat,
      symlinkJoin,
      writeShellScript,
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

      sourcePackage =
        args:
        pkgs.runCommand "${args.pname}-${args.version}" args ''
          ln -s "$src" "$out"
        '';

      armClient = sourcePackage rec {
        pname = "steam-client-arm64";
        version = "5448e08ec5f3a4f30d900208b18598c736b3d730";
        src = fetchurl {
          url = "https://client-update.steamstatic.com/bins_linuxarm64_linuxarm64.zip.${version}";
          hash = "sha256-hAc0fcR2Xs+Rki3BxhIfM1YjOu3ERh5GPgjpt6s/rhA=";
        };
      };

      armRuntime = sourcePackage rec {
        pname = "steam-runtime-arm64";
        version = "3c.0.20261103.268067";
        src = fetchurl {
          url = "https://repo.steampowered.com/steamrt3c/images/${version}/steam-runtime-steamrt-arm64.tar.xz";
          hash = "sha256-vEwTGdJO29Io5i+nzTUecw/PHJ1WjEl90jYJhg6WWWA=";
        };
        passthru.installer = sourcePackage {
          pname = "steam-runtime-arm64-installer";
          inherit version;
          src = fetchurl {
            url = "https://repo.steampowered.com/steamrt3c/images/${version}/steam-runtime-steamrt-arm64.sh";
            hash = "sha256-gD1aX0rBmAAkULV+9Th98jQ1P4PKASBJwvazqaE8y7k=";
          };
        };
      };

      armRuntimeInstaller = armRuntime.installer;

      steamUnwrapped = pkgs.steam-unwrapped.overrideAttrs (old: {
        nativeBuildInputs = old.nativeBuildInputs or [ ] ++ [ pkgs.unzip ];
        prePatch = old.prePatch or "" + ''
          tar -xJOf bootstraplinux_ubuntu12_32.tar.xz steam.sh > steam-arm64.sh
        '';
        patches = old.patches or [ ] ++ [
          (pkgs.replaceVars ./steam-arm64.patch { inherit armRuntimeInstaller; })
        ];
        postPatch = old.postPatch or "" + ''
          mkdir bootstrap
          unzip -q ${armClient} -d bootstrap
          chmod +x bootstrap/steamrtarm64/steam
          mkdir -p bootstrap/package
          printf 'publicbeta\n' > bootstrap/package/beta
          touch bootstrap/.steam-enable-steamrt64-client
          tar -cJf bootstraplinux_linuxarm64.tar.xz -C bootstrap .
          rm bootstraplinux_ubuntu12_32.tar.xz
        '';
        # Package upgrades refresh these references; Valve manages extraction.
        postInstall = old.postInstall or "" + ''
          install -m755 steam-arm64.sh "$out/lib/steam/steam-arm64.sh"
          mkdir -p "$out/lib/steam/steam-runtime-arm64"
          ln -s ${armRuntime} "$out/lib/steam/steam-runtime-arm64/steam-runtime-steamrt-arm64.tar.xz"
          tar -xJOf ${armRuntime} steam-runtime-steamrt-arm64/VERSIONS.txt \
            > "$out/lib/steam/steam-runtime-arm64/steam-runtime-steamrt-arm64.VERSIONS.txt"
        '';
      });

      steam = pkgs.steam.override {
        steam-unwrapped = steamUnwrapped;
        # Upstream's multilib ldconfig/ldd package is x86-specific.
        buildFHSEnv =
          args:
          buildFHSEnv (
            args
            // {
              multiArch = false;
              targetPkgs = p: args.targetPkgs (p // { glibc_multi = p.glibc; });
            }
          );
        inherit extraLibraries;
        extraPkgs = p: [ p.lsof ] ++ extraPkgs p;
        inherit extraEnv;
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
      passthru = {
        run = wrapMuvm steamX86.run { };
        inherit armClient armRuntime;
        updateScript = lib.getExe (
          pkgs.writeShellApplication {
            name = "update-muvm-steam";
            runtimeInputs = with pkgs; [
              curl
              gawk
              nix-update
            ];
            text = builtins.readFile ./update.sh;
          }
        );
      };
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
