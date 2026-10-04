{
  flake.aspects.nixvim.homeManager =
    { self', ... }:
    {
      programs.nixvim = {
        plugins = {
          jupynvim = {
            enable = true;

            package = self'.packages.jupynvim;

            settings.core_path = "${self'.packages.jupynvim}/bin/jupynvim-core";
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
