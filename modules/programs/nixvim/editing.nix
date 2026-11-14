{
  profiles.pc.homeModule =
    { lib, self', ... }:
    {
      programs.nixvim = {
        plugins = {
          jupynvim = {
            enable = true;

            package = self'.packages.jupynvim.overrideAttrs (prev: {
              patches = prev.patches or [ ] ++ [
                ./jupynvim-render.patch
                ./jupynvim-format.patch
              ];
            });

            settings.core_path = lib.getExe self'.packages.jupynvim;
            settings.before_save.__raw = ''
              function(buf) require("notebook-format").format_buffer(buf) end
            '';
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
