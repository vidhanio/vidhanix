{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:
stdenvNoCC.mkDerivation {
  pname = "ghostty-shader-playground";
  version = "0-unstable-2025-10-13";

  src = fetchFromGitHub {
    owner = "KroneCorylus";
    repo = "ghostty-shader-playground";
    rev = "7b0c94df4c5dfeb6686edeb9ef8d89456bbc8ae3";
    hash = "";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/shaders/
    install public/shaders/*.glsl $out/share/shaders/

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--version=branch"
    ];
  };

  meta = {
    description = "Krone Corylus' Ghostty shaders";
    homepage = "https://github.com/KroneCorylus/ghostty-shader-playground";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
