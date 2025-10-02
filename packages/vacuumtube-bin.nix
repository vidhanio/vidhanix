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
    sha256 = "sha256:02g3zmwc3i2ha3wqjpfjyzs0xxxdw1b0hj0q1wb9qd43mpcv8xq7";
  };

  icon = fetchurl {
    url = "https://raw.githubusercontent.com/shy1132/VacuumTube/refs/heads/main/assets/icon.svg";
    sha256 = "sha256-3XrxLr43jYBNwLpS6sOJDfm3wtiOYWCR+E+VgFDZT3I=";
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

    mkdir -p $out/{opt/vacuumtube,bin}

    mv * $out/opt/vacuumtube

    chmod +x $out/opt/vacuumtube/vacuumtube
    ln -s $out/opt/vacuumtube/vacuumtube $out/bin/

    cp $icon $out/opt/vacuumtube/icon.svg
    mkdir -p $out/share/icons/hicolor/scalable/apps
    ln -s $out/opt/vacuumtube/icon.svg $out/share/icons/hicolor/scalable/apps/vacuumtube.svg

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
