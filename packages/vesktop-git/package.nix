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
    version = "1.5.8-unstable-2025-10-06";

    src = previousAttrs.src.override {
      rev = "8cc34e217c70700c5d24451fa89cbe53e92b7f0a";
      hash = "sha256-8EVx4q7jNOpWAf1djOqHrG2GlQf7bq7vYUjWaihUfDw=";
    };

    pnpmDeps = previousAttrs.pnpmDeps.override {
      hash = "sha256-Vn+Imarp1OTPfe/PoMgFHU5eWnye5Oa+qoGZaTxOUmU=";
    };

    passthru.updateScript = nix-update-script {
      extraArgs = [
        "--flake"
        "--version=branch"
      ];
    };
  })
