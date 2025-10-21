{
  hardware.asahi.peripheralFirmwareDirectory = ./firmware;

  boot.kernel.sysfs.bus.hid.drivers.apple.module.parameters = {
    fnmode = 2;
    swap_ctrl_cmd = true;
  };
}
