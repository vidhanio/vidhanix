{
  flake.modules = {
    nixos.default = {
      programs.neovim.enable = true;
      environment.shellAliases.vi = "nvim";
    };
    homeManager.default = {
      programs.neovim.enable = true;
    };
  };
}
