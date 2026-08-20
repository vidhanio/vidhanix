let
  pkg =
    {
      lib,
      stdenvNoCC,
      fetchFromGitHub,
      nix-update-script,
    }:
    stdenvNoCC.mkDerivation (finalAttrs: {
      pname = "pi-context-view";
      version = "0.4.3";

      src = fetchFromGitHub {
        owner = "dimk90";
        repo = "pi-context-view";
        rev = "v${finalAttrs.version}";
        hash = "sha256-BEJNRx/YsNmTgJQHJ5xDnlG6NfO8dinjfBlC4iyUfXk=";
      };

      phases = [
        "unpackPhase"
        "installPhase"
      ];

      # No runtime dependencies (only the pi-bundled @earendil-works/*), so
      # just ship what the npm tarball would: the files listed in "files".
      installPhase = ''
        mkdir -p $out
        cp -r src package.json README.md LICENSE $out/
      '';

      passthru.updateScript = nix-update-script {
        extraArgs = [ "--flake" ];
      };

      meta = {
        description = "Pi extension to visualize context usage and inspect the hidden parts: base prompt, tools defs, and extension injections";
        homepage = "https://github.com/dimk90/pi-context-view";
        license = lib.licenses.mit;
      };
    });
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages.pi-context-view = pkgs.callPackage pkg { };
    };
}
