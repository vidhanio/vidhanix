{ withSystem, ... }:
{
  flake.modules.homeManager.default =
    { pkgs, ... }:
    withSystem pkgs.stdenvNoCC.hostPlatform.system (
      { self', ... }:
      {
        programs.retroarch = {
          enable = true;
          settings = (
            let
              database = "${self'.packages.libretro-database}/share/libretro/database";
            in
            {
              content_database_path = "${database}/rdb";
              cursor_directory = "${database}/cursor";
              cheat_database_path = "${database}/cht";
              system_directory = "${self'.packages.libretro-system-files}/share/libretro/system";
              # config_save_on_exit = "false";
            }
          );
        };

        persist.directories = map (d: ".config/retroarch/${d}") [
          "saves"
          "states"
        ];
      }
    );
}
