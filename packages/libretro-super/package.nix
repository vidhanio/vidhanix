{
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
  pname = "libretro-super";
  version = "Latest";

  src = fetchFromGitHub {
    owner = "libretro";
    repo = "libretro-super";
    rev = "d245eacc7fe14a6567cd1c960ca299319e4645c6";
    hash = "sha256-Y/R+0YWDix6U7Ql4lpJbHz/QcO6lAs4hrDxyedX29aY=";
  };

  phases = [
    "unpackPhase"
    "installPhase"
  ];

  installPhase = ''
    cp -r . $out
  '';
}
