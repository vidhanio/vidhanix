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
      version = "0.51.0";

      src = fetchFromGitHub {
        owner = "nicobailon";
        repo = "pi-subagents";
        rev = "v${finalAttrs.version}";
        hash = "sha256-jCvTUW6u7eHb1+2/qtjGAID5WkxXhjYA4k1HohOCIRQ=";
      };

      npmDepsHash = "sha256-kJqaHv5+vHj8F1QpK9ocsoXetdCoTtqC8aEq92yvUKk=";

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
