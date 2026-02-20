{
  flake.modules = {
    nixos.default = {
      hardware.bluetooth.enable = true;

      services.blueman.enable = true;

      persist.directories = [
        "/var/lib/bluetooth"
      ];
    };
    homeManager.default = {
      services.blueman-applet.enable = true;
    };
  };
}
