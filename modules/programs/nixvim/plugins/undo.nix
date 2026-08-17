{
  flake.aspects.nixvim.nixvim = {
    opts.undofile = true;
  };

  flake.aspects.nixvim.homeManager = {
    persist.directories = [ ".local/state/nvim/undo" ];
  };
}
