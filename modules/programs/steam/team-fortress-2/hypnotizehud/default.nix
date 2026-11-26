let
  pkg =
    {
      lib,
      pkgs,
      nushell,
      stdenvNoCC,
      fetchFromGitHub,
      nix-update-script,

      # Entries for customizations/colors.res, e.g. { Crosshair = "213 213 213 255"; }.
      colors ? { },

      # Preset font from customizations/alternative_fonts.res.
      font ? "rubik",
      # Installed font family used instead of the preset; overrides `font`.
      fontFamily ? null,

      crosshair ? { },
      hitmarker ? { },
      healthStyle ? "normal",
      damageStyle ? "medium-shadow",
      scoreboardStyle ? "full",
      teamStatusStyle ? "big",
      chat ? { },
      pauseMenuBackground ? "grey",
      # VTF copied over the main-menu background; null keeps the HUD background.
      mainMenuBackground ? null,
      # Argument passed to `engine`, e.g. "connect 1.2.3.4:27015" or "map cp_badlands".
      favoriteServer ? null,
      speedometer ? false,
      transparentViewmodels ? false,
      streamerMode ? false,
      # Aspect-ratio fixes from customizations/resolutions.
      resolution ? "16x9",
    }:
    let
      fontFiles = {
        avenir = "fonts_avenir.res";
        cerbetica = "fonts_cerbetica.res";
        futura = "fonts_futura.res";
        lato = "fonts_lato.res";
        neutra = "fonts_neutra.res";
        nexa = "fonts_nexa.res";
        product = "fonts_product.res";
        quake = "fonts_quake.res";
        renogare = "fonts_renogare.res";
        roboto = "fonts_roboto.res";
        rubik = "fonts_rubik.res";
        surface = "fonts_surface.res";
        tf2 = "fonts_tf2.res";
      };

      healthFiles = {
        normal = "hudplayerhealth_normal.res";
        box = "hudplayerhealth_box.res";
      };

      damageFiles = {
        small-shadow = "huddamage_small_shadow.res";
        medium-shadow = "huddamage_medium_shadow.res";
        big-shadow = "huddamage_big_shadow.res";
        small-outline = "huddamage_small_outline.res";
        medium-outline = "huddamage_medium_outline.res";
        big-outline = "huddamage_big_outline.res";
      };

      scoreboardFiles = {
        full = "scoreboard_fullstats.res";
        short = "scoreboard_nostats.res";
      };

      teamStatusFiles = {
        big = "hudmatchstatus_bighealth.res";
        small = "hudmatchstatus_smallhealth.res";
      };

      pauseMenuFiles = {
        grey = "pausemenugrey.res";
        transparent = "pausemenutransparent.res";
      };

      enum =
        name: value: allowed:
        if lib.elem value allowed then
          value
        else
          throw "hypnotizehud: ${name} must be one of ${
            lib.concatMapStringsSep ", " (option: ''"${option}"'') allowed
          }";

      boolean =
        name: value:
        if builtins.isBool value then value else throw "hypnotizehud: ${name} must be a boolean";

      integer =
        name: value: min: max:
        if builtins.isInt value && value >= min && value <= max then
          value
        else
          throw "hypnotizehud: ${name} must be an integer between ${toString min} and ${toString max}";

      text =
        name: value:
        if builtins.isString value && builtins.match "[^\"]+" value != null then
          value
        else
          throw "hypnotizehud: ${name} must be a non-empty string without quotes";

      color =
        name: value:
        if builtins.isString value && builtins.match "[0-9]+ [0-9]+ [0-9]+ [0-9]+" value != null then
          value
        else
          throw "hypnotizehud: color ${name} must be four space-separated integers";

      crosshairConfig = {
        enable = false;
        type = "?";
        size = 18;
        outline = false;
        shadow = false;
        xpos = "cs-0.5";
        ypos = "cs-0.5";
        animate = false;
      }
      // crosshair;

      hitmarkerConfig = {
        enable = false;
        type = "s";
        size = 24;
        outline = false;
        xpos = "cs-0.5";
        ypos = "cs-0.5";
      }
      // hitmarker;

      chatConfig = {
        xpos = "2";
        ypos = "45";
        background = null;
      }
      // chat;

      fontName = enum "font" font (builtins.attrNames fontFiles);
      fontFamilyConfig =
        if fontFamily == null then
          null
        else if builtins.isString fontFamily && builtins.match "[^\"]+" fontFamily != null then
          fontFamily
        else
          throw "hypnotizehud: fontFamily must be a non-empty string without quotes";

      mainMenuBackgroundConfig =
        if mainMenuBackground == null then
          null
        else if lib.hasSuffix ".vtf" (toString mainMenuBackground) then
          toString mainMenuBackground
        else
          throw "hypnotizehud: mainMenuBackground must be a .vtf file";

      favoriteServerConfig =
        if favoriteServer == null then
          null
        else if !(builtins.isString favoriteServer) then
          throw "hypnotizehud: favoriteServer must be a string"
        else if !(lib.hasPrefix "connect " favoriteServer || lib.hasPrefix "map " favoriteServer) then
          throw "hypnotizehud: favoriteServer must start with \"connect \" or \"map \""
        else
          favoriteServer;

      config = pkgs.writeText "hypnotizehud-config.json" (
        builtins.toJSON {
          font = if fontFamilyConfig == null then fontFiles.${fontName} else null;
          fontFamily = fontFamilyConfig;
          colors = lib.mapAttrs (name: value: color name value) colors;
          crosshair = {
            enable = boolean "crosshair.enable" crosshairConfig.enable;
            type = text "crosshair.type" crosshairConfig.type;
            size = integer "crosshair.size" crosshairConfig.size 10 30;
            outline = boolean "crosshair.outline" crosshairConfig.outline;
            shadow = boolean "crosshair.shadow" crosshairConfig.shadow;
            xpos = text "crosshair.xpos" crosshairConfig.xpos;
            ypos = text "crosshair.ypos" crosshairConfig.ypos;
            animate = boolean "crosshair.animate" crosshairConfig.animate;
          };
          hitmarker = {
            enable = boolean "hitmarker.enable" hitmarkerConfig.enable;
            type = text "hitmarker.type" hitmarkerConfig.type;
            size = integer "hitmarker.size" hitmarkerConfig.size 10 30;
            outline = boolean "hitmarker.outline" hitmarkerConfig.outline;
            xpos = text "hitmarker.xpos" hitmarkerConfig.xpos;
            ypos = text "hitmarker.ypos" hitmarkerConfig.ypos;
          };
          health = healthFiles.${enum "healthStyle" healthStyle (builtins.attrNames healthFiles)};
          damage = damageFiles.${enum "damageStyle" damageStyle (builtins.attrNames damageFiles)};
          scoreboard =
            scoreboardFiles.${enum "scoreboardStyle" scoreboardStyle (builtins.attrNames scoreboardFiles)};
          teamStatus =
            teamStatusFiles.${enum "teamStatusStyle" teamStatusStyle (builtins.attrNames teamStatusFiles)};
          chat = {
            xpos = text "chat.xpos" chatConfig.xpos;
            ypos = text "chat.ypos" chatConfig.ypos;
            background =
              if chatConfig.background == null then null else color "chat.background" chatConfig.background;
          };
          pauseMenuBackground =
            pauseMenuFiles.${
              enum "pauseMenuBackground" pauseMenuBackground (builtins.attrNames pauseMenuFiles)
            };
          mainMenuBackground = mainMenuBackgroundConfig;
          favoriteServer = favoriteServerConfig;
          speedometer = boolean "speedometer" speedometer;
          transparentViewmodels = boolean "transparentViewmodels" transparentViewmodels;
          streamerMode = boolean "streamerMode" streamerMode;
          resolution = enum "resolution" resolution [
            "4x3"
            "5x4"
            "16x10"
            "16x9"
          ];
        }
      );
    in
    stdenvNoCC.mkDerivation {
      pname = "hypnotizehud";
      version = "1.7-unstable-2025-10-10";

      src = fetchFromGitHub {
        owner = "Hypnootize";
        repo = "hypnotizehud";
        rev = "fcd6d541b9909a1f12c2185eff5eed4840b0a26b";
        hash = "sha256-RdvxfB0ISN8PdP/PR7q0b8fJRj9yykXkkbZm+GjdQ6Q=";
      };

      nativeBuildInputs = [ nushell ];

      dontConfigure = true;
      dontBuild = true;

      installPhase = ''
        runHook preInstall

        cp -a . "$out"
        ${nushell}/bin/nu --no-config-file ${./customizer.nu} --root "$out" --config ${config}

        runHook postInstall
      '';

      passthru.updateScript = nix-update-script {
        extraArgs = [ "--version=branch" ];
      };

      meta = {
        description = "HypnotizeHUD for Team Fortress 2";
        homepage = "https://github.com/Hypnootize/hypnotizehud";
        license = lib.licenses.unfreeRedistributable;
        platforms = lib.platforms.linux;
      };
    };
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages.hypnotizehud = pkgs.callPackage pkg { };
    };
}
