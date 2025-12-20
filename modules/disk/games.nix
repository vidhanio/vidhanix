{
  flake.modules.nixos.default = {
    disko.devices.disk.games = {
      type = "disk";
      device = "/dev/disk/by-id/ata-SHPP41-2000GM_ANDAN55971120B355";
      destroy = false;
      content = {
        type = "gpt";
        partitions = {
          games = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/mnt/games";
              mountOptions = [
                "noauto"
                "x-systemd.automount"
              ];
            };
          };
        };
      };
    };
  };
}
