{
  flake.aspects.upower = {
    nixos = {
      services.upower.enable = true;
    };
  };
}
