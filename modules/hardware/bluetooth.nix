{
  flake.modules.nixos.default = {
    hardware.bluetooth.enable = true;

    persist.directories = [
      "/var/lib/bluetooth"
    ];
  };
}
