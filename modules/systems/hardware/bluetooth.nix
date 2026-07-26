{
  den.default = {
    nixos = {
      hardware.bluetooth.enable = true;

      services.blueman.enable = true;

      persist.directories = [
        "/var/lib/bluetooth"
      ];
    };
    homeManager = {
      services.blueman-applet.enable = true;
    };
  };
}
