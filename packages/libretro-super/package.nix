{
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:
stdenvNoCC.mkDerivation {
  pname = "libretro-super";
  version = "Latest-unstable-2025-12-21";

  src = fetchFromGitHub {
    owner = "libretro";
    repo = "libretro-super";
    rev = "6244066badefb5ccca99e621ce0e653748bb8f37";
    hash = "sha256-ttAlK4vZIMHLpm4yklaGSJrPwGUIm3Ta2Bo2w0S8gX8=";
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
