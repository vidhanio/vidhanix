let
  pkg =
    {
      lib,
      buildNpmPackage,
      fetchFromGitHub,
      nix-update-script,
    }:
    buildNpmPackage (finalAttrs: {
      pname = "pi-web-access";
      version = "0.24.0";

      src = fetchFromGitHub {
        owner = "nicobailon";
        repo = "pi-web-access";
        rev = "v${finalAttrs.version}";
        hash = "sha256-1E6ogt3gL+UhuLaTiLYlcDgjKar9AP3izuDEk1erXlI=";
      };

      # Upstream's lockfile auto-includes the @earendil-works/pi-* peer
      # dependencies with missing integrity fields (unfetchable). pi installs
      # packages with --legacy-peer-deps, so vendor a lockfile generated the
      # same way: `npm install --package-lock-only --legacy-peer-deps`.
      postPatch = ''
        cp ${./pi-web-access.package-lock.json} package-lock.json
      '';

      npmDepsHash = "sha256-hFnpkvT6kGhbsIzkLE4XOP9/n7tTX4gUD4qtSR8F8rc=";

      npmFlags = [ "--legacy-peer-deps" ];

      # The extension runs from source TypeScript; there is nothing to build.
      dontNpmBuild = true;

      passthru.updateScript = nix-update-script {
        extraArgs = [ "--flake" ];
      };

      meta = {
        description = "Web search and content extraction extension for Pi coding agent";
        homepage = "https://github.com/nicobailon/pi-web-access";
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
