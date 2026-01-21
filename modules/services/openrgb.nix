{
  flake.modules.nixos.default = {
    services.hardware.openrgb.enable = true;
  };
}
