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
      version = "0.29.0";

      src = fetchFromGitHub {
        owner = "nicobailon";
        repo = "pi-web-access";
        tag = "v${finalAttrs.version}";
        hash = "sha256-5YMwE44pyMmCapGt9kFLxT61Qg3OCzuJCIATRhMBv6M=";
      };

      # pi provides these peer dependencies itself.
      postPatch = ''
        ${lib.getExe jq} '
          .packages |= with_entries(select(.value.peer != true))
        ' package-lock.json > package-lock.json.tmp
        mv package-lock.json.tmp package-lock.json
      '';

      npmDepsHash = "sha256-2JNFeY3KP6gqXC7npvBw781Sl8Oc3DsdZCdUGu5Ykh8=";
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
