{ lib, ... }:
{
  profiles.pc.homeModule =
    {
      config,
      pkgs,
      self',
      ...
    }:
    let
      stylixColors = config.lib.stylix.colors;
      rgb =
        name: alpha:
        "${stylixColors."${name}-rgb-r"} ${stylixColors."${name}-rgb-g"} ${stylixColors."${name}-rgb-b"} ${toString alpha}";
      opaque = name: rgb name 255;

      qualityColors = {
        Normal = opaque "base03";
        Genuine = opaque "base0B";
        Unusual = opaque "base0E";
        Vintage = opaque "base0D";
        Unique = opaque "base0A";
        Community = opaque "base0B";
        Developer = opaque "base0E";
        SelfMade = opaque "base0B";
        Customized = opaque "base0D";
        Strange = opaque "base09";
        Completed = opaque "base0C";
        Haunted = opaque "base0C";
        Collectors = opaque "base08";
        PaintkitWeapon = opaque "base06";
        GradedWeaponDefault = opaque "base04";
        CivilianGrade = opaque "base06";
        FreelanceGrade = opaque "base0C";
        MercenaryGrade = opaque "base0D";
        CommandoGrade = opaque "base0E";
        AssassinGrade = opaque "base09";
        EliteGrade = opaque "base08";
      };

      themeColors = {
        Crosshair = opaque "base05";
        Crosshair_Shadow = opaque "base00";
        Crosshair_Pulse = opaque "base08";

        HitMarker = opaque "base08";

        Health_Numbers = opaque "base05";

        Shadow = rgb "base00" 175;

        Buffed_Health = opaque "base0D";
        Buffed_Health_Pulse = opaque "base0C";

        Low_Health = opaque "base08";
        Low_Health_Pulse = opaque "base08";

        Ammo_In_Clip = opaque "base05";
        Ammo_In_Reserve = opaque "base05";
        Ammo_No_Clip = opaque "base05";

        Low_Ammo_In_Clip = opaque "base08";
        Low_Ammo_In_Clip_Pulse = opaque "base08";
        Low_Ammo_In_Reserve = opaque "base08";
        Low_Ammo_In_Reserve_Pulse = opaque "base08";
        Low_Ammo_No_Clip = opaque "base08";
        Low_Ammo_No_Clip_Pulse = opaque "base08";

        Full_Ubercharge = opaque "base0D";
        Full_Ubercharge_Pulse = opaque "base0C";

        Heal_Numbers = opaque "base0B";
        Last_Damage_Done = opaque "base05";

        Health_Gained = opaque "base0B";
        Health_Lost = opaque "base08";

        Red = opaque "base08";
        Blue = opaque "base0D";
        Green = opaque "base0B";

        Main_Theme = opaque "base0D";
        White = opaque "base05";
        White_Dark = opaque "base04";
        White_Gray = opaque "base03";
        Gray_Light = opaque "base03";
        Gray_Medium = opaque "base01";
        Gray_Dark = opaque "base01";
        Gray_Darker = opaque "base00";
        Gray_Darkest = opaque "base00";
        Black_Light = opaque "base00";
        Black_Dark = opaque "base00";
        Black = opaque "base00";
        TransparentBlack = rgb "base00" 150;
        TransparentLightBlack = rgb "base00" 100;
      }
      // qualityColors
      // lib.mapAttrs' (name: value: lib.nameValuePair "${name}_Hover" value) qualityColors;

      hypnotizehud = self'.packages.hypnotizehud.override {
        colors = themeColors;
        fontFamily = "${config.stylix.fonts.sansSerif.name} ExtraBold";
        chat = {
          background = rgb "base00" 200;
        };
        pauseMenuBackground = "transparent";
      };

      fetchGameBananaFile =
        {
          id,
          hash,
          name,
          path,
        }:
        pkgs.runCommandLocal (baseNameOf path)
          {
            nativeBuildInputs = [ pkgs.libarchive ];
          }
          ''
            bsdtar -xOf ${
              pkgs.fetchurl {
                inherit name hash;
                url = "https://gamebanana.com/dl/${id}";
              }
            } ${path} > "$out"
          '';

      trWalkway = fetchGameBananaFile {
        id = "329543";
        name = "tr_walkway_rc2.rar";
        hash = "sha256-k145fwdSqyXoNrR/8gTlFPA9SxjrIrVUBi1j9XlHt5w=";
        path = "tr_walkway_rc2.bsp";
      };

      trRocketShooting = fetchGameBananaFile {
        id = "338360";
        name = "tr_rocket_shooting2.zip";
        hash = "sha256-X4/VbO9H+FFmq4NXFgbs3y2EQUk3aFi0RUXR1Jk7baM=";
        path = "tr_rocket_shooting2/tr_rocket_shooting2.bsp";
      };
    in
    {
      programs.steam.config = lib.mkIf pkgs.stdenv.hostPlatform.isx86_64 {
        apps."440" = {
          name = "Team Fortress 2";
          args = [
            "-novid"
            "-nohltv"
            "-particles"
            "1"
            "-nostartupsound"
            "-fullscreen"
          ];

          files.game = {
            place = {
              "tf/custom/hypnotizehud".source = hypnotizehud;
              "tf/custom/loadouts.vpk".source = ./assets/loadouts.vpk;
              "tf/custom/mastercomfig-base.vpk".source =
                "${self'.packages.mastercomfig}/presets/mastercomfig-base.vpk";
              "tf/custom/tf/cfg/app/damagenumbers.cfg".text = ''
                hud_combattext 1
                hud_combattext_red ${toString (lib.toInt stylixColors."base05-rgb-r")}
                hud_combattext_green ${toString (lib.toInt stylixColors."base05-rgb-g")}
                hud_combattext_blue ${toString (lib.toInt stylixColors."base05-rgb-b")}
              '';
              "tf/custom/tf/cfg/app/setup_hook.cfg".source = ./assets/tf/cfg/app/setup_hook.cfg;
              "tf/custom/tf/cfg/jump.cfg".source = ./assets/tf/cfg/jump.cfg;
              "tf/custom/tf/cfg/overrides".source = ./assets/tf/cfg/overrides;
              "tf/custom/tf/maps/tr_rocket_shooting2.bsp".source = trRocketShooting;
              "tf/custom/tf/maps/tr_walkway_rc2.bsp".source = trWalkway;
              "tf/custom/tf/scripts".source = ./assets/tf/scripts;
              "tf/custom/tf/sound/ui".source = ./assets/tf/sound/ui;
            };
          };
        };
      };
    };
}
