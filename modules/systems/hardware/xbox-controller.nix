{
  flake.aspects.hardware = {
    nixos = {
      hardware.xpadneo.enable = true;

      boot.extraModprobeConfig = ''
        options hid_xpadneo rumble_attenuation=50
      '';
    };
  };
}
