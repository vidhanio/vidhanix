{
  flake.modules.nixos.default = {
    disko.devices.disk.games = {
      type = "disk";
      device = "/dev/disk/by-id/ata-WD_BLACK_SN7100X_4TB_25458E800155";
      destroy = false;
      content = {
        type = "gpt";
        partitions = {
          games = {
            size = "100%";
            content = {
              type = "btrfs";
              mountpoint = "/mnt/games";
              mountOptions = [
                "compress=zstd"
                "noatime"
                "noauto"
                "x-systemd.automount"
              ];
              subvolumes = {
                steam = { };
              };
            };
          };
        };
      };
    };
  };
}
