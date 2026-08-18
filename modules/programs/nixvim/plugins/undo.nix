{
  flake.aspects.nixvim = {
    nixvim = {
      opts.undofile = true;
    };
    homeManager = {
      persist.directories = [ ".local/state/nvim/undo" ];
    };
  };
}
