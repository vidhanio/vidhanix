{
  profiles.pc = {
    module = {
      programs.niri.enable = true;
    };

    homeModule = {
      wayland.windowManager.niri.enable = true;
    };
  };
}
