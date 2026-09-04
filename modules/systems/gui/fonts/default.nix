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
        mkConsoleFont =
          {
            package,
            name,
            size,
          }:
          pkgs.stdenvNoCC.mkDerivation {
            pname = "console-font";
            version = "1";

            dontUnpack = true;

            nativeBuildInputs = [
              pkgs.bdf2psf
              pkgs.fontconfig
              pkgs.otf2bdf
            ];

            FONTCONFIG_FILE = pkgs.makeFontsConf {
              fontDirectories = [ package ];
            };
            FONT_NAME = name;
            FONT_PACKAGE = package;
            FONT_SIZE = toString size;

            buildPhase = ''
              runHook preBuild

              fontFile=
              fallbackFont=
              while IFS= read -r -d "" candidate; do
                metadata="$(fc-scan --format '%{family[0]}\t%{style[0]}\t%{slant}' "$candidate")"
                IFS=$'\t' read -r family style slant <<< "$metadata"

                if [[ "$family" == "$FONT_NAME" && "$slant" == 0 ]]; then
                  if [[ -z "$fallbackFont" ]]; then
                    fallbackFont="$candidate"
                  fi
                  if [[ -z "$fontFile" ]]; then
                    case "$style" in
                      Book | Medium | Normal | Regular)
                        fontFile="$candidate"
                        ;;
                    esac
                  fi
                fi
              done < <(
                find "$FONT_PACKAGE" -type f \
                  \( -iname '*.otf' -o -iname '*.ttf' \) -print0
              )

              fontFile="''${fontFile:-$fallbackFont}"
              if [[ -z "$fontFile" ]]; then
                echo "No upright font matching $FONT_NAME found in $FONT_PACKAGE" >&2
                exit 1
              fi

              # otf2bdf returns the byte count of ENDFONT on success.
              otf2bdf \
                -c M \
                -o font.bdf \
                -p "$FONT_SIZE" \
                -r 96 \
                "$fontFile" || test "$?" -eq 8
              test -s font.bdf

              # bdf2psf requires AVERAGE_WIDTH in whole pixels.
              width="$(sed -n 's/^DWIDTH \([0-9][0-9]*\) 0$/\1/p' font.bdf | sed -n '1p')"
              test -n "$width"
              sed -i "s/^AVERAGE_WIDTH .*/AVERAGE_WIDTH $((width * 10))/" font.bdf

              bdf2psf --fb \
                font.bdf \
                ${pkgs.bdf2psf}/share/bdf2psf/standard.equivalents \
                :${pkgs.bdf2psf}/share/bdf2psf/ascii.set+:${pkgs.bdf2psf}/share/bdf2psf/useful.set+:${pkgs.bdf2psf}/share/bdf2psf/linux.set \
                512 \
                font.psfu

              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall

              install -Dm644 font.psfu "$out/share/consolefonts/console.psfu"

              runHook postInstall
            '';
          };

        consoleFont = mkConsoleFont {
          package = cfg.fonts.monospace.package;
          name = cfg.fonts.monospace.name;
          size = builtins.floor cfg.fonts.sizes.terminal;
        };

      in
      {
        console.font = "${consoleFont}/share/consolefonts/console.psfu";

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
