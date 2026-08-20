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
      version = "0.52.1";

      src = fetchFromGitHub {
        owner = "nicobailon";
        repo = "pi-subagents";
        rev = "v${finalAttrs.version}";
        hash = "sha256-mx8AtxX8JEW+wg+2ypRknb08WnCJj6P9MfL4FapaR7o=";
      };

      npmDepsHash = "sha256-pxhGx0W53nVdj3FLeC3PGnQIksYTlDVZMOUxBOnrSzg=";

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
