{
  flake.aspects.fish = {
    homeManager = {
      persist.files = [
        {
          file = ".local/share/fish/fish_history";
          how = "symlink";
        }
      ];
    };
  };
}
