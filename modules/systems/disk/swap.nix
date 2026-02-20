{
  flake.modules.nixos = {
    default = {
      disko.devices.disk.main.content.partitions.root.content.subvolumes.swap = {
        mountpoint = "/swap";
        swap.swapfile.size = "16G";
      };

      boot.kernel.sysfs.module.zswap.parameters.enabled = 1;
    };
  };
}
