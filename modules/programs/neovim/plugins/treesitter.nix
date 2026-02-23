{
  flake.modules.nixvim.default = {
    plugins.treesitter = {
      enable = true;
      highlight.enable = true;
      indent.enable = true;
      folding.enable = true;
      statuscolumn.enable = true;
    };
  };
}
