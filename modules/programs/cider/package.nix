let
  pkg =
    {
      lib,
      stdenv,
      fetchurl,
      autoPatchelfHook,
      makeWrapper,
      gsettings-desktop-schemas,
      dconf,
      alsa-lib,
      gtk3,
      libgbm,
      libGL,
      libnotify,
      nspr,
      nss,
      xdg-utils,
      coreutils,
      curl,
      dpkg,
      gnugrep,
      gnused,
      gnutar,
      nix,
      writeShellScript,
    }:
    let
      sources = {
        aarch64-linux = {
          suffix = "arm64";
          hash = "sha256-HA68YE3z08yFg+1OETondI44ysT/PKjRmntObS+nTe4=";
        };
        x86_64-linux = {
          suffix = "x64";
          hash = "sha256-CanpS0yydWOkGKp/8SIVSJ7EavFUs9xBxUgmL9AUXJU=";
        };
      };
      source = sources.${stdenv.hostPlatform.system};
    in
    stdenv.mkDerivation (finalAttrs: {
      pname = "cider";
      version = "4.0.17";

      src = fetchurl {
        url = "https://repo.cider.sh/apt/pool/main/cider-v${finalAttrs.version}-linux-${source.suffix}.deb";
        inherit (source) hash;
      };

      nativeBuildInputs = [
        autoPatchelfHook
        dpkg
        gnutar
        makeWrapper
      ];

      buildInputs = [
        alsa-lib
        gtk3
        libgbm
        libnotify
        nspr
        nss
      ];

      appendRunpaths = lib.makeLibraryPath [ libGL ];

      unpackPhase = ''
        runHook preUnpack

        ${lib.getExe' dpkg "dpkg-deb"} --fsys-tarfile "$src" |
          ${lib.getExe' gnutar "tar"} --extract

        runHook postUnpack
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p "$out"/{bin,share,lib}
        cp -r usr/share/* "$out/share/"
        cp -r usr/lib/* "$out/lib/"

        chmod +x "$out/lib/cider/Cider"
        makeWrapper "$out/lib/cider/Cider" "$out/bin/cider" \
          --add-flags "\$\{NIXOS_OZONE_WL:+\$\{WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true\}\}" \
          --add-flags "--no-sandbox --disable-gpu-sandbox" \
          --prefix XDG_DATA_DIRS : "${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}" \
          --prefix XDG_DATA_DIRS : "${gtk3}/share/gsettings-schemas/${gtk3.name}" \
          --prefix GIO_EXTRA_MODULES : "${dconf.lib}/lib/gio/modules" \
          --suffix PATH : "${xdg-utils}/bin" \
          --set GDK_PIXBUF_MODULE_FILE "$GDK_PIXBUF_MODULE_FILE"

        runHook postInstall
      '';

      postFixup = ''
        install -Dm444 "$out/share/pixmaps/cider.png" \
          "$out/share/icons/hicolor/256x256/apps/cider.png"

        rm -rf "$out/share/pixmaps" "$out/share/lintian"
        rm -f \
          "$out/lib/cider/resources/Cider.desktop" \
          "$out/lib/cider/resources/Cider.flatpak.desktop" \
          "$out/lib/cider/resources/public/icon.icns" \
          "$out/lib/cider/resources/public/icon-osx-previous.icns" \
          "$out/lib/cider/resources/public/icon.ico"
      '';

      passthru.updateScript =
        let
          curlExe = lib.getExe curl;
          grepExe = lib.getExe gnugrep;
          nixExe = lib.getExe nix;
          prefetchExe = lib.getExe' nix "nix-prefetch-url";
          sedExe = lib.getExe' gnused "sed";
          sortExe = lib.getExe' coreutils "sort";
          packageIndex = "https://repo.cider.sh/apt/pool/main/";
        in
        writeShellScript "update-cider" ''
          set -euo pipefail

          package_file=modules/programs/cider/package.nix
          latest_version="$(
            ${curlExe} --fail --silent --show-error --location ${packageIndex} |
              ${grepExe} --only-matching --extended-regexp 'cider-v[0-9]+([.][0-9]+){2,3}-linux-(arm64|x64)[.]deb' |
              ${sedExe} -nE 's/^cider-v([0-9]+([.][0-9]+){2,3})-linux-(arm64|x64)[.]deb$/\1/p' |
              ${sortExe} --version-sort |
              ${sedExe} -n '$p'
          )"

          if [[ -z "$latest_version" ]]; then
            echo "Could not find the latest Cider version" >&2
            exit 1
          fi

          old_version="$(${sedExe} -nE 's/^[[:space:]]*version = "([^"]+)";/\1/p' "$package_file")"
          echo "cider: $old_version -> $latest_version"
          if [[ "$old_version" == "$latest_version" ]]; then
            echo "Already up to date!"
            exit 0
          fi

          prefetch_hash() {
            local hash
            hash="$(${prefetchExe} --quiet --type sha256 "$1")"
            ${nixExe} --experimental-features nix-command hash convert \
              --hash-algo sha256 --from nix32 "$hash"
          }

          arm_hash="$(prefetch_hash "https://repo.cider.sh/apt/pool/main/cider-v$latest_version-linux-arm64.deb")"
          x64_hash="$(prefetch_hash "https://repo.cider.sh/apt/pool/main/cider-v$latest_version-linux-x64.deb")"

          quote='"'
          ${sedExe} --in-place --regexp-extended \
            -e "s|^([[:space:]]*version = )$quote.*$quote;|\1$quote$latest_version$quote;|" \
            -e "/aarch64-linux = [{]/,/^[[:space:]]*};/ s|^([[:space:]]*hash = )$quote.*$quote;|\1$quote$arm_hash$quote;|" \
            -e "/x86_64-linux = [{]/,/^[[:space:]]*};/ s|^([[:space:]]*hash = )$quote.*$quote;|\1$quote$x64_hash$quote;|" \
            "$package_file"
        '';

      meta = {
        description = "A cross-platform Apple Music experience built on Vue.js and written from the ground up with performance in mind";
        homepage = "https://cider.sh";
        downloadPage = "https://cider.sh/downloads";
        license = lib.licenses.unfree;
        mainProgram = "cider";
        platforms = lib.attrNames sources;
        sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
      };
    });
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages.cider = pkgs.callPackage pkg { };
    };
}
