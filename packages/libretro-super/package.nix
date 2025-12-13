{
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:
stdenvNoCC.mkDerivation {
  pname = "libretro-super";
  version = "Latest-unstable-2025-12-07";

  src = fetchFromGitHub {
    owner = "libretro";
    repo = "libretro-super";
    rev = "4ea922bd9a89684779684693121dda7297d45ade";
    hash = "sha256-+acFG7bV89Dll6sIXb1mswKLMKIumHRPL3w+N8Tx1y4=";
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
