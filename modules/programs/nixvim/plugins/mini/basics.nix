{
  flake.aspects.nixvim.nixvim = {
    plugins.mini.modules.basics = {
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
  };
}
