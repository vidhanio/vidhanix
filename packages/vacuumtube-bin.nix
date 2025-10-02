{
  lib,
  stdenv,
  autoPatchelfHook,
  copyDesktopItems,
  makeDesktopItem,
  alsa-lib,
  atk,
  cairo,
  cups,
  dbus,
  glib,
  gtk3,
  libgbm,
  libx11,
  libxext,
  libxkbcommon,
  nss,
  pango,
  xorg,
  fetchurl,
  ...
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "vacuumtube-bin";
  version = "1.3.16";

  src = fetchTarball {
    url = "https://github.com/shy1132/VacuumTube/releases/download/v${finalAttrs.version}/VacuumTube-x64.tar.gz";
    sha256 = "sha256:0ycb1ylvsairvv96qz7a8pchawyxbn5mra5dx6cmz7dqi3k0dk79";
  };

  icon = fetchurl {
    url = "https://raw.githubusercontent.com/shy1132/VacuumTube/refs/heads/main/assets/icon.svg";
    sha256 = "";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
  ];

  buildInputs = [
    alsa-lib
    atk
    cairo
    cups
    dbus
    glib
    gtk3
    libgbm
    libx11
    libxext
    libxkbcommon
    nss
    pango
    xorg.libXcomposite
    xorg.libXcomposite
    xorg.libXfixes
    xorg.libXrandr
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "vacuumtube";
      icon = "vacuumtube";
      exec = "vacuumtube";
      desktopName = "VacuumTube";
      genericName = "Video Player";
      categories = [
        "AudioVideo"
        "Audio"
        "Video"
      ];
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{opt/$pname,bin}

    mv * $out/opt/$pname

    chmod +x $out/opt/$pname/$pname
    ln -s $out/opt/$pname/$pname $out/bin/

    cp $icon $out/opt/$pname/icon.svg
    mkdir -p $out/share/icons/hicolor/scalable/apps
    ln -s $out/opt/$pname/icon.svg $out/share/icons/hicolor/scalable/apps/vacuumtube.svg

    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/shy1132/VacuumTube";
    description = "YouTube Leanback on the desktop, with enhancements";
    mainProgram = "vacuumtube";
    maintainers = [ "vidhanio" ];
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
})
