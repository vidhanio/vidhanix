{
  flake.modules.nixos.default = {
    hardware.logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };
  };
}
