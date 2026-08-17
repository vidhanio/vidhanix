{
  flake.aspects.hardware.nixos = {
    hardware.bluetooth.enable = true;

    persist.directories = [
      "/var/lib/bluetooth"
    ];
  };
}
