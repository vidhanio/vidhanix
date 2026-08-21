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
      lib,
      stdenvNoCC,
      breezex-cursor,
      hyprcursor,
      python3,
      xcur2png,

      baseColor ? "#000000",
      outlineColor ? "#FFFFFF",
    }:
    stdenvNoCC.mkDerivation (finalAttrs: {
      pname = "breezex-hyprcursor";
      inherit (breezex-cursor) version src;

      nativeBuildInputs = [
        hyprcursor
        python3
        xcur2png
      ];

      buildPhase = ''
        runHook preBuild

        theme="extracted_BreezeX Cursor"
        hyprcursor-util -x "${breezex-cursor}/share/icons/BreezeX Cursor" -o .
        python3 ${./prepare-hyprcursor.py} "$theme" ./svg \
          ${lib.escapeShellArg baseColor} ${lib.escapeShellArg outlineColor}

        cat > "$theme/manifest.hl" << EOF
        name = BreezeX Cursor
        description = Extended KDE cursor
        version = ${finalAttrs.version}
        cursors_directory = hyprcursors
        EOF

        hyprcursor-util -c "$theme"
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
