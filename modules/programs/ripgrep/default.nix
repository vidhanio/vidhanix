{
  profiles.base = {
    homeModule = {
      programs.ripgrep = {
        enable = true;
        arguments = [ "--hidden" ];
      };
    };
  };
}
