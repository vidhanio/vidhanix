let
  pkg =
    {
      lib,
      buildNpmPackage,
      fetchFromGitHub,
      nix-update-script,
    }:
    buildNpmPackage (finalAttrs: {
      pname = "pi-subagents";
      version = "0.50.0";

      src = fetchFromGitHub {
        owner = "nicobailon";
        repo = "pi-subagents";
        rev = "v${finalAttrs.version}";
        hash = "sha256-2lv3e6s+AVXL5Da/+PhSzG4b5Hc62+2MY0mjqSPBoVo=";
      };

      npmDepsHash = "sha256-X8kf/dRx2TQyMJIxG5NeqmBtOOh7VMjD0xw1wgVcBMs=";

      # The extension runs from source TypeScript; there is nothing to build.
      dontNpmBuild = true;

      passthru.updateScript = nix-update-script {
        extraArgs = [ "--flake" ];
      };

      meta = {
        description = "Pi extension for async subagent delegation with truncation, artifacts, and session sharing";
        homepage = "https://github.com/nicobailon/pi-subagents";
        license = lib.licenses.mit;
      };
    });
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages.pi-subagents = pkgs.callPackage pkg { };
    };
}
