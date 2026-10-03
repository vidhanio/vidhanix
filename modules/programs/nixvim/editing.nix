{
  flake.aspects.nixvim.homeManager = {
    programs.nixvim = {
      plugins = {
        sleuth.enable = true;
        todo-comments.enable = true;
        ts-comments.enable = true;

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
              relnum_in_visual_mode = true;
            };
          };
          bufremove = { };
          comment = { };
          icons = { };
          pairs = { };
          surround = { };
          trailspace = { };
        };
      };
    };
  };
}
