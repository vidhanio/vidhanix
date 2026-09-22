let
  pkg =
    {
      lib,
      buildNpmPackage,
      fetchFromGitHub,
      jq,
      nix-update-script,
    }:
    buildNpmPackage (finalAttrs: {
      pname = "pi-web-access";
      version = "0.30.0";

      src = fetchFromGitHub {
        owner = "nicobailon";
        repo = "pi-web-access";
        tag = "v${finalAttrs.version}";
        hash = "sha256-B8Ca1AH0OGM8nOKoWLI8Xukx0NNwU8FN84WzADa0v7c=";
      };

      # pi provides these peer dependencies itself.
      postPatch = ''
        ${lib.getExe jq} '
          .packages |= with_entries(select(.value.peer != true))
        ' package-lock.json > package-lock.json.tmp
        mv package-lock.json.tmp package-lock.json
      '';

      npmDepsHash = "sha256-35zF88VshuAuPWWNpCbEhslck68tVNz1MtamRxju4+Q=";
      npmFlags = [ "--legacy-peer-deps" ];

      # the extension runs from source typescript; there is nothing to build.
      dontNpmBuild = true;

      passthru.updateScript = nix-update-script {
        extraArgs = [ "--flake" ];
      };

      meta = {
        description = "Web search and content extraction extension for Pi coding agent";
        homepage = "https://github.com/nicobailon/pi-web-access";
        changelog = "https://github.com/nicobailon/pi-web-access/releases/tag/v${finalAttrs.version}";
        license = lib.licenses.mit;
      };
    });
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages.pi-web-access = pkgs.callPackage pkg { };
    };
}
