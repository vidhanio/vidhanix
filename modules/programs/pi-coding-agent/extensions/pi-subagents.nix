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
      version = "0.69.0";

      src = fetchFromGitHub {
        owner = "nicobailon";
        repo = "pi-subagents";
        tag = "v${finalAttrs.version}";
        hash = "sha256-j6nEmECD1jDXBCgc65AJMa6QFtbRYq4TblGB7ghQ1Ms=";
      };

      npmDepsHash = "sha256-K9gDFwFEoXO8ekGOaSoq8OQ2CEVjX8kwOtY7PEdDWnw=";
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
