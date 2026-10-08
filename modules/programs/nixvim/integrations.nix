{
  profiles.pc.homeModule = {
    programs.nixvim.plugins = {
      direnv.enable = true;
      image.enable = true;
      typst-preview.enable = true;
      wakatime.enable = true;
    };
  };
}
