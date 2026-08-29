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
      version = "0.59.0";

      src = fetchFromGitHub {
        owner = "nicobailon";
        repo = "pi-subagents";
        tag = "v${finalAttrs.version}";
        hash = "sha256-jAVMtYlImA8Cg+UyU0dAZWN7LyA0Z0WsczxXvQ1plbs=";
      };

      npmDepsHash = "sha256-Rdm4REYhKfFZkwpTLpEpsiqF03OTLfQp+z49q+JSqpE=";
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
