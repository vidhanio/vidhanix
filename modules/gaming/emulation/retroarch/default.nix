{ withSystem, ... }:
{
  flake.modules.homeManager.default =
    { pkgs, ... }:
    {
      programs.retroarch = {
        enable = true;
        settings = let
            self' = withSystem pkgs.stdenv.hostPlatform.system ({ self', ... }: self');
            database = "${self'.packages.libretro-database}/share/libretro/database";
          in
          {
            content_database_path = "${database}/rdb";
            cursor_directory = "${database}/cursor";
            cheat_database_path = "${database}/cht";
            system_directory = "${self'.packages.libretro-system-files}/share/libretro/system";
            # config_save_on_exit = "false";
            menu_swap_ok_cancel_buttons = "true";
            input_player1_joypad_index = "1"; # Controller
          };
      };

      persist.directories = map (d: ".config/retroarch/${d}") [
        "saves"
        "states"
      ];
    };
}
