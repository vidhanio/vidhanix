{
  perSystem.treefmt.settings.excludes = [
    "modules/systems/hosts/vidhan-macbook/firmware/*"
  ];

  den.aspects.vidhan-macbook.nixos = {
    hardware.asahi.peripheralFirmwareDirectory = ./firmware;
  };
}
