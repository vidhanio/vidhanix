{
  flake.modules.nixvim.default = {
    plugins.mini = {
      enable = true;
      mockDevIcons = true;
      modules.icons = { };
    };
  };
}
