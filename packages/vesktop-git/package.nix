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
    version = "1.6.1-unstable-2025-10-28";

    src = previousAttrs.src.override {
      rev = "9193ed58c9ad995da2c648ebe6286bda4e506e25";
      hash = "sha256-ZFAsyH+5duKerZissOR/lESLetqqEMLk86msLlQO1xU=";
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
