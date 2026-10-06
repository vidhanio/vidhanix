{
  profiles.base = {
    homeModule = {
      programs.git = {
        signing = {
          format = "ssh";
          key = "~/.ssh/id_ed25519";
          signByDefault = true;
        };
      };
    };
  };
}
