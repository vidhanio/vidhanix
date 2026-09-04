{
  flake.aspects.difftastic = {
    homeManager = {
      programs.difftastic = {
        enable = true;
        git.enable = true;
        jujutsu.enable = true;
      };
    };
  };
}
