{
  flake.aspects.hardware = {
    nixos = {
      services.fwupd.enable = true;
    };
  };
}
