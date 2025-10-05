{
  hardware = {
    enableAllFirmware = true;
    cpu.amd.updateMicrocode = true;

    bluetooth.enable = true;

    logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };
  };

  services.libinput = {
    enable = true;
    mouse.accelProfile = "flat";
  };
}
