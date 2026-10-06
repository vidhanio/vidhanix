{
  hosts.vortex.module.disko.devices = {
    disk.main.content.partitions.ESP = {
      start = "1M";
      end = "500M";
    };
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "mode=755"
        "size=8G"
        "noatime"
      ];
    };
  };
}
