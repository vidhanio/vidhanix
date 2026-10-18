{
  profiles.base = {
    module.programs.direnv = {
      enable = true;
      silent = true;
    };
    homeModule = {
      persist.directories = [
        ".local/share/direnv/allow"
      ];
    };
  };
}
