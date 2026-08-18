{
  flake.aspects.tmux = {
    homeManager = {
      programs.tmux.enable = true;
    };
  };
}
