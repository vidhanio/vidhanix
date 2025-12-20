{
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:
stdenvNoCC.mkDerivation {
  pname = "libretro-super";
  version = "Latest-unstable-2025-12-20";

  src = fetchFromGitHub {
    owner = "libretro";
    repo = "libretro-super";
    rev = "66669345636be8c1a10e6afc319ca19346390853";
    hash = "sha256-XOJ2uSmjvZF00jNWl9TTZp+vgEUhJ+rNv96KvSWgCi0=";
  };

  phases = [
    "unpackPhase"
    "installPhase"
  ];

  installPhase = ''
    cp -r . $out
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--version=branch"
    ];
  };
}
