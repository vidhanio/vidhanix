{
  boot = {
    initrd.availableKernelModules = [ "usb_storage" ];

    loader = {
      systemd-boot.enable = true;
    };

    binfmt.emulatedSystems = [ "x86_64-linux" ];
  };
}
