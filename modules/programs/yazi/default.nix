{
  flake.aspects.yazi = {
    homeManager = {
      programs.yazi.enable = true;

      persist.directories = [ ".local/state/yazi" ];
    };
  };
}
