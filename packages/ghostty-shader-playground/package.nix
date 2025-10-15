{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  unstableGitUpdater,
}:
stdenvNoCC.mkDerivation {
  pname = "ghostty-shader-playground";
  version = "0-unstable-2025-10-13";

  src = fetchFromGitHub {
    owner = "KroneCorylus";
    repo = "ghostty-shader-playground";
    rev = "7b0c94df4c5dfeb6686edeb9ef8d89456bbc8ae3";
    hash = "sha256-ha45+1ri4LciepHX4Y5BIi883T4t7dT7CTuhq/9Z4EA=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/shaders/
    install public/shaders/*.glsl $out/share/shaders/

    runHook postInstall
  '';

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Krone Corylus' Ghostty shaders";
    homepage = "https://github.com/KroneCorylus/ghostty-shader-playground";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ vidhanio ];
    platforms = lib.platforms.all;
  };
}
