final: prev: {
  vacuumtube = prev.stdenv.mkDerivation rec {
    pname = "vacuumtube";
    version = "1.3.14";

    src = fetchTarball {
      url = "https://github.com/shy1132/VacuumTube/releases/download/v${version}/VacuumTube-x64.tar.gz";
      sha256 = "sha256:0yrl472a1hq27zccv12rxjrml5zi4idhcm3a8s2gbp4x33cq3ixp";
    };

    iconSrc = ./icon.svg;

    nativeBuildInputs = with final; [
      autoPatchelfHook
      copyDesktopItems
    ];

    buildInputs = with final; [
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
      (prev.makeDesktopItem {
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

      cp $iconSrc $out/opt/$pname/icon.svg
      mkdir -p $out/share/icons/hicolor/scalable/apps
      ln -s $out/opt/$pname/icon.svg $out/share/icons/hicolor/scalable/apps/vacuumtube.svg

      runHook postInstall
    '';
  };
}
