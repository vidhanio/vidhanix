{
  boot = {
    initrd.availableKernelModules = [ "usb_storage" ];

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = false;
    };
  };
}
