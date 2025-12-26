{
  pkgs,
  withSystem,
  ...
}:
{
  flake.modules.homeManager.default = {
    programs.retroarch = {
      enable = true;
      settings = withSystem pkgs.stdenvNoCC.hostPlatform.system (
        { self', ... }:
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
  };
}
