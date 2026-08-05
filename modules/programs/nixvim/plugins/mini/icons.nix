{
  flake.modules.nixvim.default = {
    plugins.mini = {
      mockDevIcons = true;
      modules.icons = { };
    };
  };
}
