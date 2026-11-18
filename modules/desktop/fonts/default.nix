{
  profiles.pc = {
    module =
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
              pkgs.installFonts
              pkgs.nerd-font-patcher
              pkgs.parallel
            ];

            enableParallelBuilding = true;

            dontUnpack = true;

            buildPhase = ''
              runHook preBuild

              find "$src" -type f \( -name \*.ttf -o -name \*.otf \) -print0 |
                parallel --null --will-cite --jobs="$NIX_BUILD_CORES" nerd-font-patcher -c -out .

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
            sansSerif = {
              package = self'.packages.allo;
              name = "Allo Variable";
            };
          };
        };
      };

    homeModule =
      { self', ... }:
      {
        home.packages = [ self'.packages.berkeley-mono ];
      };
  };
}
