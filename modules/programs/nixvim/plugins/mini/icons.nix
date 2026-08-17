{
  flake.aspects.nixvim.nixvim = {
    plugins.mini = {
      mockDevIcons = true;
      modules.icons = { };
    };
  };
}
