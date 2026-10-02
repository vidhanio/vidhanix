{
  flake.aspects.nixvim.homeManager = {
    programs.nixvim.plugins = {
      direnv.enable = true;
      image.enable = true;
      wakatime.enable = true;
    };
  };
}
