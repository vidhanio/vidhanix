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
      version = "0.31.0";

      src = fetchFromGitHub {
        owner = "nicobailon";
        repo = "pi-web-access";
        tag = "v${finalAttrs.version}";
        hash = "sha256-ykR2slh8MkxxbP660h0rvk2Y7SaKv+Cw/lJC21JqGW8=";
      };

      # pi provides the package's peer dependencies itself.
      postPatch = ''
        ${lib.getExe jq} '
          .peerDependencies = {}
          | .devDependencies |= with_entries(
              select(.key | startswith("@earendil-works/pi-") | not)
            )
        ' package.json > package.json.tmp
        mv package.json.tmp package.json

        ${lib.getExe jq} '
          .packages[""].peerDependencies = {}
          | .packages[""].devDependencies |= with_entries(
              select(.key | startswith("@earendil-works/pi-") | not)
            )
          | .packages |= with_entries(
              select(.key | startswith("node_modules/@earendil-works/pi-") | not)
            )
        ' package-lock.json > package-lock.json.tmp
        mv package-lock.json.tmp package-lock.json
      '';

      npmDepsHash = "sha256-hgBPVN/BY2R5ZPO7na7wtGg9te03xWU9/0DpYgLkicY=";
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
