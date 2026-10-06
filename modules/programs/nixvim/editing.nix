{
  profiles.pc.homeModule =
    { lib, self', ... }:
    {
      programs.nixvim = {
        plugins = {
          jupynvim = {
            enable = true;

            package = self'.packages.jupynvim;

            settings.core_path = lib.getExe self'.packages.jupynvim;
          };

          sleuth.enable = true;
          todo-comments.enable = true;

          mini.modules = {
            ai = { };
            basics = {
              options = {
                basic = true;
                extra_ui = true;
                win_borders = "auto";
              };
              mappings = {
                basic = true;
                windows = true;
                move_with_alt = true;
              };
              autocommands = {
                basic = true;
              };
            };
            bufremove = { };
            icons = { };
            pairs = { };
            surround = { };
            trailspace = { };
          };
        };
      };
    };
}
