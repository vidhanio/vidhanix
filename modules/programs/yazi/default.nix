{
  profiles.base = {
    homeModule = {
      programs.yazi.enable = true;

      persist.directories = [ ".local/state/yazi" ];
    };
  };
}
