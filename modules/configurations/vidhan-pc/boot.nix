{
  configurations.vidhan-pc.module = {
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
  };
}
