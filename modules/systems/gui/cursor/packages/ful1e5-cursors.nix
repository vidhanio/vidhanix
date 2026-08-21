let
  breezexCursor =
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

        cbmp -d svg -bc ${lib.escapeShellArg baseColor} -oc ${lib.escapeShellArg outlineColor}
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

  breezexHyprcursor =
    {
      lib,
      breezex-cursor,
      mkHyprcursor,
      python3,

      baseColor ? "#000000",
      outlineColor ? "#FFFFFF",
    }:
    mkHyprcursor {
      xcursor = breezex-cursor.override { inherit baseColor outlineColor; };
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

  breezexCombined =
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

  bibataCursor =
    {
      lib,
      stdenvNoCC,
      fetchFromGitHub,
      cbmp,
      clickgen,
      zip,
      nix-update-script,

      style ? "Modern",
      rightHand ? false,
      baseColor ? "#000000",
      outlineColor ? "#FFFFFF",
      watchBackgroundColor ? baseColor,
    }:
    let
      checkedStyle =
        if
          lib.elem style [
            "Modern"
            "Original"
          ]
        then
          style
        else
          throw "unsupported Bibata cursor style: ${style}";
      sourceDirectory = lib.toLower checkedStyle + lib.optionalString rightHand "-right";
      configDirectory = if rightHand then "right" else "normal";
    in
    stdenvNoCC.mkDerivation (finalAttrs: {
      pname = "bibata-cursor";
      version = "2.0.7";

      src = fetchFromGitHub {
        owner = "ful1e5";
        repo = "Bibata_Cursor";
        tag = "v${finalAttrs.version}";
        hash = "sha256-kIKidw1vditpuxO1gVuZeUPdWBzkiksO/q2R/+DUdEc=";
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

        cbmp -d svg/${sourceDirectory} -o bitmaps \
          -bc ${lib.escapeShellArg baseColor} \
          -oc ${lib.escapeShellArg outlineColor} \
          -wc ${lib.escapeShellArg watchBackgroundColor}
        ctgen configs/${configDirectory}/x.build.toml -p x11 -d bitmaps \
          -o $out/share/icons -n "Bibata Cursor" -c "Material based cursor theme"

        runHook postBuild
      '';

      passthru.updateScript = nix-update-script {
        extraArgs = [ "--flake" ];
      };

      meta = {
        description = "Material based cursor theme";
        homepage = "https://github.com/ful1e5/Bibata_Cursor";
        changelog = "https://github.com/ful1e5/Bibata_Cursor/releases/tag/${finalAttrs.src.tag}";
        license = lib.licenses.gpl3Only;
        platforms = lib.platforms.all;
      };
    });

  bibataHyprcursor =
    {
      lib,
      bibata-cursor,
      mkHyprcursor,
      python3,

      style ? "Modern",
      rightHand ? false,
      baseColor ? "#000000",
      outlineColor ? "#FFFFFF",
      watchBackgroundColor ? baseColor,
    }:
    let
      overrides = {
        inherit
          style
          rightHand
          baseColor
          outlineColor
          watchBackgroundColor
          ;
      };
      sourceDirectory = lib.toLower style + lib.optionalString rightHand "-right";
    in
    mkHyprcursor {
      xcursor = bibata-cursor.override overrides;
      themeName = "Bibata Cursor";
      pname = "bibata-hyprcursor";
      inherit (bibata-cursor) src;

      extraNativeBuildInputs = [ python3 ];
      postExtract = ''
        python3 ${./prepare-hyprcursor.py} "$extractedTheme" ./svg/${sourceDirectory} \
          ${lib.escapeShellArg baseColor} \
          ${lib.escapeShellArg outlineColor} \
          ${lib.escapeShellArg watchBackgroundColor}
      '';

      description = bibata-cursor.meta.description;
      meta = bibata-cursor.meta // {
        description = "Bibata Cursor theme adapted for hyprcursor";
      };
    };

  bibataCombined =
    {
      symlinkJoin,
      bibata-cursor,
      bibata-hyprcursor,

      style ? "Modern",
      rightHand ? false,
      baseColor ? "#000000",
      outlineColor ? "#FFFFFF",
      watchBackgroundColor ? baseColor,
    }:
    let
      overrides = {
        inherit
          style
          rightHand
          baseColor
          outlineColor
          watchBackgroundColor
          ;
      };
    in
    symlinkJoin {
      name = "bibata-combined-cursor";
      paths = [
        (bibata-cursor.override overrides)
        (bibata-hyprcursor.override overrides)
      ];
      meta = bibata-cursor.meta // {
        description = "Bibata Cursor theme combining both Xcursor and hyprcursor versions";
      };
    };

  googleCursor =
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
      pname = "google-cursor";
      version = "2.0.0";

      src = fetchFromGitHub {
        owner = "ful1e5";
        repo = "Google_Cursor";
        tag = "v${finalAttrs.version}";
        hash = "sha256-vzNtm3gwkGjHlC2G7dTsieQLOu67GnB3BIUSD6pZ6AA=";
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

        cbmp -d svg -n "Google Cursor" \
          -bc ${lib.escapeShellArg baseColor} \
          -oc ${lib.escapeShellArg outlineColor}
        # cbmp cannot render the upstream animated SVGs.
        cp bitmaps/GoogleDot-Black/{left_ptr_watch,wait}-*.png "bitmaps/Google Cursor"
        ctgen build.toml -p x11 -d "bitmaps/Google Cursor" -o $out/share/icons \
          -n "Google Cursor" -c "Opensource cursor theme inspired by Google"

        runHook postBuild
      '';

      passthru.updateScript = nix-update-script {
        extraArgs = [ "--flake" ];
      };

      meta = {
        description = "Opensource cursor theme inspired by Google";
        homepage = "https://github.com/ful1e5/Google_Cursor";
        changelog = "https://github.com/ful1e5/Google_Cursor/releases/tag/${finalAttrs.src.tag}";
        license = lib.licenses.gpl3Plus;
        platforms = lib.platforms.all;
      };
    });

  googleHyprcursor =
    {
      google-cursor,
      mkHyprcursor,

      baseColor ? "#000000",
      outlineColor ? "#FFFFFF",
    }:
    mkHyprcursor {
      xcursor = google-cursor.override { inherit baseColor outlineColor; };
      themeName = "Google Cursor";
      pname = "google-hyprcursor";
      inherit (google-cursor) src;
      meta = google-cursor.meta // {
        description = "Google Cursor theme adapted for hyprcursor";
      };
    };

  googleCombined =
    {
      symlinkJoin,
      google-cursor,
      google-hyprcursor,

      baseColor ? "#000000",
      outlineColor ? "#FFFFFF",
    }:
    symlinkJoin {
      name = "google-combined-cursor";
      paths = [
        (google-cursor.override { inherit baseColor outlineColor; })
        (google-hyprcursor.override { inherit baseColor outlineColor; })
      ];
      meta = google-cursor.meta // {
        description = "Google Cursor theme combining both Xcursor and hyprcursor versions";
      };
    };
in
{
  perSystem =
    { pkgs, self', ... }:
    let
      mkHyprcursor = pkgs.callPackage ./_mk-hyprcursor.nix { };
    in
    {
      packages = {
        breezex-cursor = pkgs.callPackage breezexCursor { };
        breezex-hyprcursor = pkgs.callPackage breezexHyprcursor {
          inherit mkHyprcursor;
          inherit (self'.packages) breezex-cursor;
        };
        breezex-combined = pkgs.callPackage breezexCombined {
          inherit (self'.packages) breezex-cursor breezex-hyprcursor;
        };

        bibata-cursor = pkgs.callPackage bibataCursor { };
        bibata-hyprcursor = pkgs.callPackage bibataHyprcursor {
          inherit mkHyprcursor;
          inherit (self'.packages) bibata-cursor;
        };
        bibata-combined = pkgs.callPackage bibataCombined {
          inherit (self'.packages) bibata-cursor bibata-hyprcursor;
        };

        google-cursor = pkgs.callPackage googleCursor { };
        google-hyprcursor = pkgs.callPackage googleHyprcursor {
          inherit mkHyprcursor;
          inherit (self'.packages) google-cursor;
        };
        google-combined = pkgs.callPackage googleCombined {
          inherit (self'.packages) google-cursor google-hyprcursor;
        };
      };
    };
}
