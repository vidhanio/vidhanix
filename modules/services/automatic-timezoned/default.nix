{
  flake.aspects.automatic-timezoned = {
    nixos = {
      services.automatic-timezoned.enable = true;
    };
  };
}
