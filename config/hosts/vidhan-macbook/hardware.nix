{
  hardware.asahi.peripheralFirmwareDirectory = ./firmware;

  boot.extraModprobeConfig = ''
    options hid_apple swap_ctrl_cmd=1
  '';
}
