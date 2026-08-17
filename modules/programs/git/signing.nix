{
  flake.aspects.git.homeManager = {
    programs.git = {
      signing = {
        format = "ssh";
        key = "~/.ssh/id_ed25519";
        signByDefault = true;
      };
    };
  };
}
