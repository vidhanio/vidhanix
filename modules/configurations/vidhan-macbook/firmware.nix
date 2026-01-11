{
  perSystem.treefmt.settings.excludes = [
    "modules/configurations/vidhan-macbook/firmware/*"
  ];

  configurations.vidhan-macbook.module = {
    hardware.asahi.peripheralFirmwareDirectory = ./firmware;
  };
}
