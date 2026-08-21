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
      breezex-cursor,
      mkHyprcursor,
      python3,

      baseColor ? "#000000",
      outlineColor ? "#FFFFFF",
    }:
    mkHyprcursor {
      xcursor = breezex-cursor;
      themeName = "BreezeX Cursor";
      pname = "breezex-hyprcursor";
      inherit (breezex-cursor) src;

      extraNativeBuildInputs = [ python3 ];
      postExtract = ''
        python3 ${./prepare-hyprcursor.py} "$extractedTheme" ./svg \
          ${lib.escapeShellArg baseColor} ${lib.escapeShellArg outlineColor}
      '';

      description = breezex-cursor.meta.description;
      meta = breezex-cursor.meta // {
        description = "BreezeX Cursor theme adapted for hyprcursor";
      };
    };

  combined =
    {
      symlinkJoin,
      breezex-cursor,
      breezex-hyprcursor,

      baseColor ? "#000000",
      outlineColor ? "#FFFFFF",
    }:
    symlinkJoin {
      name = "breezex-combined-cursor";
      paths = [
        (breezex-cursor.override { inherit baseColor outlineColor; })
        (breezex-hyprcursor.override { inherit baseColor outlineColor; })
      ];
      meta = breezex-cursor.meta // {
        description = "BreezeX Cursor theme combining both Xcursor and hyprcursor versions";
      };
    };
in
{
  perSystem =
    { pkgs, self', ... }:
    {
      packages = {
        breezex-cursor = pkgs.callPackage cursor { };
        breezex-hyprcursor = pkgs.callPackage hyprcursor {
          inherit (self'.packages) breezex-cursor;
          mkHyprcursor = pkgs.callPackage ./_mk-hyprcursor.nix { };
        };
        breezex-combined = pkgs.callPackage combined {
          inherit (self'.packages) breezex-cursor breezex-hyprcursor;
        };
      };
    };
}
