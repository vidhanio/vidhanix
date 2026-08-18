{
  flake.aspects.lazygit = {
    homeManager = {
      programs.lazygit = {
        enable = true;
      };

      persist.directories = [ ".local/state/lazygit" ];
    };
  };
}
