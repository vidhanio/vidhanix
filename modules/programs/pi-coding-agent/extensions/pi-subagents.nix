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
      version = "0.65.1";

      src = fetchFromGitHub {
        owner = "nicobailon";
        repo = "pi-subagents";
        tag = "v${finalAttrs.version}";
        hash = "sha256-/l5CXGrA4ik3qpGBJKsjqeDL/esFu74mocBlq//WUMs=";
      };

      npmDepsHash = "sha256-rVMH0m5XkzL6lAXrzkn2ZphkEKkFoGJyz4n3648ekXU=";
      npmFlags = [ "--legacy-peer-deps" ];

      # the extension runs from source typescript; there is nothing to build.
      dontNpmBuild = true;

      passthru.updateScript = nix-update-script {
        extraArgs = [ "--flake" ];
      };

      meta = {
        description = "Pi extension for single-agent delegation and scripted multi-agent workflows";
        homepage = "https://github.com/nicobailon/pi-subagents";
        changelog = "https://github.com/nicobailon/pi-subagents/releases/tag/v${finalAttrs.version}";
        downloadPage = "https://www.npmjs.com/package/pi-subagents";
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
