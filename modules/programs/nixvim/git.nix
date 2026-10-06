{
  profiles.pc.homeModule = {
    programs.nixvim.plugins.mini.modules = {
      diff.view = {
        style = "sign";
        signs = {
          add = "│";
          change = "│";
          delete = "│";
        };
      };
      git = { };
    };
  };
}
