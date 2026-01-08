{
  flake.modules.nixos.default = {
    hardware.xpadneo.enable = true;

    boot.extraModprobeConfig = ''
      options hid_xpadneo rumble_attenuation=50
    '';
  };
}
