{
  flake.modules.nixos.default = {
    programs.neovim.enable = true;
    environment = {
      variables.EDITOR = "nvim";
      shellAliases.vi = "nvim";
    };
  };
}
