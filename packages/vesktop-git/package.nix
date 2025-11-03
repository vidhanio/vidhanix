{
  vesktop,
  nix-update-script,
  ...
}@args:
(vesktop.override (
  removeAttrs args [
    "vesktop"
    "nix-update-script"
  ]
)).overrideAttrs
  (previousAttrs: {
    version = "1.6.1-unstable-2025-11-03";

    src = previousAttrs.src.override {
      rev = "f57245f297c972de7f1ee1e0707305d7f5c7f7dc";
      hash = "sha256-RYGxl5pFkhri0KZF6t97jibBX4Mn0rWB/yzfcVcwqS4=";
    };

    pnpmDeps = previousAttrs.pnpmDeps.override {
      hash = "sha256-7fYD4lTSLCMOa+CqGlL45Mjw6qMfIJddPcRF5/dGGrk=";
    };

    passthru.updateScript = nix-update-script {
      extraArgs = [
        "--flake"
        "--version=branch"
      ];
    };
  })
