{
  flake.aspects.fonts = {
    nixos =
      {
        self',
        pkgs,
        config,
        ...
      }:
      let
        cfg = config.stylix;

        patchNerdFont =
          font:
          pkgs.stdenv.mkDerivation {
            pname = "${font.pname}-nerd-font";
            inherit (font) version;

            src = font;

            nativeBuildInputs = [
              pkgs.nerd-font-patcher
              pkgs.parallel
            ];

            buildPhase = ''
              runHook preBuild

              find . -type f -name \*.ttf -print0 |
                parallel --null --will-cite nerd-font-patcher -c -out "$out/share/fonts/truetype"  
              find . -type f -name \*.otf -print0 |
                parallel --null --will-cite nerd-font-patcher -c -out "$out/share/fonts/opentype"

              runHook postBuild
            '';
          };
      in
      {
        stylix = {
          fonts = {
            monospace = {
              package = patchNerdFont self'.packages.berkeley-mono;
              name = "BerkeleyMono Nerd Font";
            };
            serif = cfg.fonts.monospace;
            sansSerif = cfg.fonts.monospace;
          };
        };
      };
  };
}
