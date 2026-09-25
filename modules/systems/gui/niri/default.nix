{
  flake.aspects.niri = {
    nixos = {
      programs.niri.enable = true;
    };

    homeManager = {
      wayland.windowManager.niri.enable = true;
    };
  };
}
