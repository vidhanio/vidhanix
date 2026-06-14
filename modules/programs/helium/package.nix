let
  pkg =
    {
      stdenv,
      lib,
      fetchurl,
      makeWrapper,
      autoPatchelfHook,
      copyDesktopItems,
      makeDesktopItem,
      _experimental-update-script-combinators,
      nix-update-script,

      # Runtime/build deps
      alsa-lib,
      at-spi2-atk,
      at-spi2-core,
      atk,
      cairo,
      cups,
      dbus,
      expat,
      fontconfig,
      freetype,
      gdk-pixbuf,
      glib,
      gtk3,
      kdePackages,
      libdrm,
      libgbm,
      libGL,
      libpulseaudio,
      libva,
      libvdpau,
      libx11,
      libxcb,
      libxcomposite,
      libxcursor,
      libxdamage,
      libxext,
      libxfixes,
      libxi,
      libxkbcommon,
      libxrandr,
      libxrender,
      libxscrnsaver,
      libxshmfence,
      libxtst,
      libuuid,
      mesa,
      nspr,
      nss,
      pango,
      pipewire,
      systemd,
      vulkan-loader,
      wayland,
      widevine-cdm,
    }:
    let
      # Chromium flags applied on all platforms to disable update machinery.
      commonFlags = [
        "--disable-component-update"
        "--simulate-outdated-no-au='Tue, 31 Dec 2099 23:59:59 GMT'"
        "--check-for-update-interval=0"
        "--no-first-run"
        "--enable-features=StorageAccessAPI"
        "--restore-last-session"
      ];

      addFlags = lib.concatMapStringsSep " \\\n      " (f: "--add-flags \"${f}\"");

      # Libraries that must appear on LD_LIBRARY_PATH at runtime on Linux.
      linuxRuntimeLibs = [
        libGL
        libvdpau
        libva
        pipewire
        alsa-lib
        libpulseaudio
      ];

      inherit (stdenv.hostPlatform) system;

      platforms = {
        x86_64-linux = {
          arch = "x86_64";
          hash = "sha256-MXV5LVknmxhYPq5+W6O2QYz3bemw1nxLs4kI+pS3Mgs=";
        };
        aarch64-linux = {
          arch = "arm64";
          hash = "sha256-Sq7Iae93/t98uyLyDgRtEX+7n+Hc4MssZqg9n5bzNC8=";
        };
      };

      inherit (platforms.${system} or (throw "Unsupported system: ${system}")) arch hash;
    in
    stdenv.mkDerivation (finalAttrs: {
      pname = "helium-bin";
      version = "0.13.1.1";

      src = fetchurl {
        url = "https://github.com/imputnet/helium-linux/releases/download/${finalAttrs.version}/helium-${finalAttrs.version}-${arch}_linux.tar.xz";
        inherit hash;
      };

      nativeBuildInputs = [
        makeWrapper
        autoPatchelfHook
        copyDesktopItems
      ];

      buildInputs = [
        alsa-lib
        at-spi2-atk
        at-spi2-core
        atk
        cairo
        cups
        dbus
        expat
        fontconfig
        freetype
        gdk-pixbuf
        glib
        gtk3
        libdrm
        libgbm
        libGL
        libpulseaudio
        libx11
        libxcb
        libxcomposite
        libxcursor
        libxdamage
        libxext
        libxfixes
        libxi
        libxkbcommon
        libxrandr
        libxrender
        libxscrnsaver
        libxshmfence
        libxtst
        libuuid
        mesa
        nspr
        nss
        pango
        pipewire
        systemd
        vulkan-loader
        wayland
        kdePackages.qtbase
      ];

      # Qt libraries are bundled; suppress autoPatchelf warnings for them.
      autoPatchelfIgnoreMissingDeps = [
        "libQt6Core.so.6"
        "libQt6Gui.so.6"
        "libQt6Widgets.so.6"
        "libQt5Core.so.5"
        "libQt5Gui.so.5"
        "libQt5Widgets.so.5"
      ];

      dontWrapQtApps = true;

      installPhase = ''
        runHook preInstall

        mkdir -p $out/bin $out/opt/helium
        cp -r * $out/opt/helium

        makeWrapper $out/opt/helium/helium $out/bin/helium \
          --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath linuxRuntimeLibs}" \
          --add-flags "--ozone-platform-hint=auto" \
          --add-flags "--enable-features=WaylandWindowDecorations" \
          ${addFlags commonFlags}

        mkdir -p $out/share/icons/hicolor/256x256/apps
        cp $out/opt/helium/product_logo_256.png \
          $out/share/icons/hicolor/256x256/apps/helium.png

        mkdir -p $out/opt/helium/WidevineCdm
        cp -a ${widevine-cdm}/share/google/chrome/WidevineCdm/* $out/opt/helium/WidevineCdm/

        runHook postInstall
      '';

      desktopItems = [
        (makeDesktopItem {
          name = "helium";
          exec = "helium %U";
          icon = "helium";
          desktopName = "Helium";
          genericName = "Web Browser";
          categories = [
            "Network"
            "WebBrowser"
          ];
          terminal = false;
          mimeTypes = [
            "text/html"
            "text/xml"
            "application/xhtml+xml"
            "x-scheme-handler/http"
            "x-scheme-handler/https"
          ];
        })
      ];

      passthru.updateScript = _experimental-update-script-combinators.sequence [
        (nix-update-script {
          extraArgs = [
            "--flake"
            "--system=x86_64-linux"
          ];
        })
        (nix-update-script {
          extraArgs = [
            "--flake"
            "--system=aarch64-linux"
            "--version=skip"
          ];
        })
      ];

      meta = {
        description = "Private, fast, and honest web browser based on ungoogled-chromium";
        homepage = "https://helium.computer";
        license = lib.licenses.gpl3Only;
        platforms = lib.attrNames platforms;
        mainProgram = "helium";
      };
    });
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages.helium-bin = pkgs.callPackage pkg { };
    };
}
