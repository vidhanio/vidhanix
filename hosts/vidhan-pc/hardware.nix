{
  boot = {
    initrd = {
      kernelModules = [
        "amdgpu"
      ];
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usbhid"
      ];
    };
    kernelModules = [ "kvm-amd" ];
  };

  hardware = {
    enableAllFirmware = true;
    cpu.amd.updateMicrocode = true;

    bluetooth.enable = true;

    logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };
  };
}
