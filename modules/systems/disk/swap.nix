{
  flake.aspects.swap.nixos = {
    disko.devices.disk.main.content.partitions.root.content.subvolumes.swap = {
      mountpoint = "/swap";
      swap.swapfile.size = "16G";
    };

    boot.kernel.sysfs.module.zswap.parameters.enabled = 1;
    boot.kernel.sysctl = {
      "vm.swappiness" = 100;
      "vm.page-cluster" = 0;
      "vm.watermark_scale_factor" = 125;
      "vm.max_map_count" = 1048576;
    };
  };
}
