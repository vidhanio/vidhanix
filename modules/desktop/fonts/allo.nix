{
  perSystem =
    { pkgs, ... }:
    {
      packages.allo = pkgs.callPackage (
        {
          lib,
          stdenvNoCC,
          fetchzip,
          installFonts,
          nix-update-script,
        }:
        stdenvNoCC.mkDerivation (finalAttrs: {
          pname = "allo";
          version = "1.0.3";

          src = fetchzip {
            url = "https://github.com/joshpuckett/allo/releases/download/v${finalAttrs.version}/Allo-${finalAttrs.version}.zip";
            hash = "sha256-wKyKi7vS95W32sUq7ws0bZa0MwJIPUdo0dAykMGdL/g=";
          };

          outputs = [
            "out"
            "webfont"
          ];

          nativeBuildInputs = [ installFonts ];

          passthru.updateScript = nix-update-script { };

          meta = {
            description = "Friendly variable font family with weight, roundness, and optical size axes";
            homepage = "https://allo.joshpuckett.me/";
            changelog = "https://github.com/joshpuckett/allo/releases/tag/v${finalAttrs.version}";
            license = lib.licenses.ofl;
            platforms = lib.platforms.all;
          };
        })
      ) { };
    };
}
