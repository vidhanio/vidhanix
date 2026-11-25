{ lib, ... }:
{
  profiles.pc.homeModule =
    { pkgs, self', ... }:
    let
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
              "tf/custom/7hud".source = "${self'.packages._7hud}";
              "tf/custom/loadouts.vpk".source = ./assets/loadouts.vpk;
              "tf/custom/mastercomfig-base.vpk".source =
                "${self'.packages.mastercomfig}/presets/mastercomfig-base.vpk";
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
