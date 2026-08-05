{
  flake.modules = {
    nixvim.default = {
      opts.undofile = true;
    };

    homeManager.default = {
      persist.directories = [ ".local/state/nvim/undo" ];
    };
  };
}
