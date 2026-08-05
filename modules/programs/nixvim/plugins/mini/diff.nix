{
  flake.modules.nixvim.default = {
    plugins.mini.modules.diff.view = {
      style = "sign";
      signs = {
        add = "│";
        change = "│";
        delete = "│";
      };
    };
  };
}
