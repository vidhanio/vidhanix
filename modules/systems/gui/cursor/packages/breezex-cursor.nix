let
  cursor =
    {
      lib,
      stdenvNoCC,
      fetchFromGitHub,
      cbmp,
      clickgen,
      zip,
      nix-update-script,

      baseColor ? "#000000",
      outlineColor ? "#FFFFFF",
    }:
    stdenvNoCC.mkDerivation (finalAttrs: {
      pname = "breezex-cursor";
      version = "2.0.1";

      src = fetchFromGitHub {
        owner = "ful1e5";
        repo = "BreezeX_Cursor";
        tag = "v${finalAttrs.version}";
        sha256 = "sha256-P9LgQb3msq6YydK5RIk5yykUd9SL2GQbC4aH4F8LUF0=";
      };

      nativeBuildInputs = [
        (cbmp.overrideAttrs (old: {
          patches = old.patches or [ ] ++ [
            ./cbmp-disable-ora.patch
          ];
        }))
        clickgen
        zip
      ];

      buildPhase = ''
        runHook preBuild

        cbmp -d svg -bc "${baseColor}" -oc "${outlineColor}"
        ctgen ./configs/x.build.toml -p x11 -d ./bitmaps -o $out/share/icons

        runHook postBuild
      '';

      passthru.updateScript = nix-update-script {
        extraArgs = [ "--flake" ];
      };

      meta = {
        description = "Extended KDE cursor";
        homepage = "https://github.com/ful1e5/BreezeX_Cursor";
        changelog = "https://github.com/ful1e5/BreezeX_Cursor/releases/tag/${finalAttrs.src.tag}";
        license = lib.licenses.gpl3;
        platforms = lib.platforms.all;
      };
    });
  hyprcursor =
    {
      stdenvNoCC,
      breezex-cursor,
      hyprcursor,
      xcur2png,

      baseColor ? "#000000",
      outlineColor ? "#FFFFFF",
    }:
    stdenvNoCC.mkDerivation (finalAttrs: {
      pname = "breezex-hyprcursor";
      inherit (breezex-cursor) version src;

      buildInputs = [
        hyprcursor
        xcur2png
      ];

      buildPhase = ''
        runHook preBuild

        hyprcursor-util -x "${breezex-cursor}/share/icons/BreezeX Cursor" -o .

        for dir in "extracted_BreezeX Cursor/hyprcursors"/*; do
          cursor_name=$(basename "$dir")
          rm "$dir"/*.png

          if [ -d "./svg/$cursor_name" ]; then
            cp -r "./svg/$cursor_name"/*.svg "$dir"
          else
            cp "./svg/$cursor_name.svg" "$dir"
          fi

          meta_file="$dir/meta.hl"

          index=0
          tmp=$(mktemp)

          svgs=()
          for svg in "$dir"/*.svg; do
            sed -i "s/#00FF00/${baseColor}/g; s/#0000FF/${outlineColor}/g" "$svg"
            svgs+=("$(basename "$svg")")
          done

          while read -r line; do
            # continue if line does not start with "define_size = "
            if [[ ! $line =~ ^define_size\ = ]]; then
              echo $line 
              continue
            fi

            args=$(echo $line | cut -d '=' -f 2 | tr -d ' ')
            size=$(echo $args | cut -d, -f 1 | tr -d ' ')
            delay=$(echo $args | cut -d, -f 3 | tr -d ' ')

            if [ "$size" -ne 16 ]; then
              continue
            fi

            echo "define_size = 0, ''${svgs[index]}, $delay"

            index=$((index + 1))
          done < "$meta_file" > "$tmp"

          mv "$tmp" "$meta_file"
        done

        cat > "extracted_BreezeX Cursor/manifest.hl" << EOF
        name = BreezeX Cursor
        description = Extended KDE cursor
        version = ${finalAttrs.version}
        cursors_directory = hyprcursors
        EOF

        hyprcursor-util -c "extracted_BreezeX Cursor"
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out/share/icons
        cp -r "./theme_BreezeX Cursor" "$out/share/icons/BreezeX Cursor"

        runHook postInstall
      '';

      meta = breezex-cursor.meta // {
        description = "BreezeX Cursor theme adapted for hyprcursor";
      };
    });

  combined =
    {
      runCommandLocal,
      breezex-cursor,
      breezex-hyprcursor,

      baseColor ? "#000000",
      outlineColor ? "#FFFFFF",
    }:
    runCommandLocal "breezex-combined-cursor"
      {
        meta = breezex-cursor.meta // {
          description = "BreezeX Cursor theme combining both Xcursor and hyprcursor versions";
        };
      }
      ''
        mkdir -p $out/share/icons

        cp -r "${breezex-cursor.override { inherit baseColor outlineColor; }}/share/icons/BreezeX Cursor" \
          $out/share/icons/

        chmod -R u+w $out/share/icons/BreezeX\ Cursor

        cp -r "${
          breezex-hyprcursor.override { inherit baseColor outlineColor; }
        }/share/icons/BreezeX Cursor" \
          $out/share/icons/
      '';
in
{
  perSystem =
    { pkgs, self', ... }:
    {
      packages = {
        breezex-cursor = pkgs.callPackage cursor { };
        breezex-hyprcursor = pkgs.callPackage hyprcursor {
          inherit (self'.packages) breezex-cursor;
        };
        breezex-combined = pkgs.callPackage combined {
          inherit (self'.packages) breezex-cursor breezex-hyprcursor;
        };
      };
    };
}
