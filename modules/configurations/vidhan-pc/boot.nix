{
  configurations.vidhan-pc.module =
    { pkgs, ... }:
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

        loader.efi.canTouchEfiVariables = true;
        kernelPackages = pkgs.linuxPackages_latest;
      };
    };
}
