{
  flake.aspects.nixvim = {
    nixvim = {
      plugins.treesitter = {
        enable = true;
        highlight.enable = true;
        indent.enable = true;
        folding.enable = true;
      };
    };
  };
}
