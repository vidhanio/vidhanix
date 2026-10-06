{
  profiles.apple-silicon.module =
    { config, ... }:
    {
      disko.devices.disk.main.content.partitions = {
        iBootSystemContainer = {
          label = "iBootSystemContainer";
          priority = 1;
          type = "AF0B";
        };
        Container = {
          label = "Container";
          priority = 2;
          type = "AF0A";
        };
        NixOSContainer = {
          label = "NixOSContainer";
          priority = 3;
          type = "AF0A";
        };
        ESP.priority = 4;
        RecoveryOSContainer = {
          label = "RecoveryOSContainer";
          priority = 5;
          type = "AF0C";
        };
        root.content.subvolumes.tmproot = {
          mountpoint = "/";
          mountOptions = [
            "compress=zstd"
            "noatime"
          ];
        };
      };

      boot.initrd.systemd = {
        enable = true;
        services.wipe-root = {
          description = "Wipe Btrfs tmproot subvolume";
          wantedBy = [ "initrd.target" ];
          after = [ "initrd-root-device.target" ];
          before = [ "sysroot.mount" ];
          unitConfig.DefaultDependencies = "no";
          serviceConfig.Type = "oneshot";
          script = ''
            mkdir -p /mnt
            mount "${config.disko.devices.disk.main.content.partitions.root.device}" /mnt
            trap "umount /mnt" EXIT
            btrfs subvolume delete -R /mnt/tmproot || true
            btrfs subvolume create /mnt/tmproot
          '';
        };
      };
    };
}
