{
  hardware.asahi.peripheralFirmwareDirectory = ./firmware;

  boot.extraModprobeConfig = ''
    options hid_apple fnmode=2 swap_ctrl_cmd=1
  '';
}
