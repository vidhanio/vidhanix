{ config, ... }:
{
  profiles.pc = {
    module = {
      imports = [ config.profiles.base.module ];
      hardware = {
        bluetooth.enable = true;
        logitech.wireless.enable = true;
        xpadneo.enable = true;
      };
      services.fwupd.enable = true;
      boot.extraModprobeConfig = ''
        options hid_xpadneo rumble_attenuation=50
      '';
      persist.directories = [ "/var/lib/bluetooth" ];
    };
    homeModule.imports = [ config.profiles.base.homeModule ];
  };
}
