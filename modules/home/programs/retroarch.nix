{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.retroarch;
in
lib.mkMerge [
  {
    programs.retroarch.settings =
      let
        database = "${pkgs.libretro-database}/share/libretro/database";
      in
      {
        content_database_path = "${database}/rdb";
        cursor_directory = "${database}/cursor";
        cheat_database_path = "${database}/cht";
        system_directory = "${pkgs.libretro-system-files}/share/libretro/system";
        # config_save_on_exit = "false";
      };
  }
  (lib.mkIf cfg.enable {
    persist.directories = map (d: ".config/retroarch/${d}") [
      "saves"
      "states"
    ];
  })
]
