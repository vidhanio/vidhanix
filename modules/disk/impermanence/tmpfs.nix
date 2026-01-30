{
  flake.modules.nixos = {
    desktop = {
      disko.devices.nodev."/" = {
        fsType = "tmpfs";
        mountOptions = [
          "mode=755"
          "size=8G"
        ];
      };
    };
    macbook =
      { config, ... }:
      {
        disko.devices.disk.main.content.partitions.root.content.subvolumes.tmproot = {
          mountpoint = "/";
          mountOptions = [
            "compress=zstd"
            "noatime"
          ];
        };

        boot.initrd.systemd = {
          enable = true;

          services.wipe-root = {
            description = "Wipe BTRFS tmproot subvolume";
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
  };
}
