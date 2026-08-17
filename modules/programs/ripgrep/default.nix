{
  flake.aspects.ripgrep.homeManager = {
    programs.ripgrep = {
      enable = true;
      arguments = [ "--hidden" ];
    };
  };
}
