{
  flake.modules.homeManager.default = {
    programs.spicetify = {
      enable = true;
      wayland = false;
    };
  };
}
