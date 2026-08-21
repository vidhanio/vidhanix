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
      bibata-cursors,
      cbmp,
      clickgen,
      zip,

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
    stdenvNoCC.mkDerivation {
      pname = "bibata-cursor";
      inherit (bibata-cursors) version src;

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

      inherit (bibata-cursors) meta;
    };

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

  googleHyprcursor =
    {
      lib,
      google-cursor,
      mkHyprcursor,

      color ? "Black",
    }:
    let
      checkedColor =
        if
          lib.elem color [
            "Black"
            "Blue"
            "Red"
            "White"
          ]
        then
          color
        else
          throw "unsupported Google cursor color: ${color}";
      themeName = "GoogleDot-${checkedColor}";
    in
    mkHyprcursor {
      xcursor = google-cursor;
      inherit themeName;
      pname = "google-hyprcursor";
      meta = google-cursor.meta // {
        description = "${themeName} adapted for hyprcursor";
      };
    };

  googleCombined =
    {
      symlinkJoin,
      google-cursor,
      google-hyprcursor,

      color ? "Black",
    }:
    symlinkJoin {
      name = "google-combined-cursor";
      paths = [
        google-cursor
        (google-hyprcursor.override { inherit color; })
      ];
      meta = google-cursor.meta // {
        description = "Google cursor themes with a ${color} hyprcursor variant";
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

        inherit (pkgs) google-cursor;
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
