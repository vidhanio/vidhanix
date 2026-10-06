{
  profiles.pc = {
    module = {
      hardware.bluetooth.enable = true;

      persist.directories = [
        "/var/lib/bluetooth"
      ];
    };
  };
}
