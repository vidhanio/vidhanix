{ config, ... }:
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-SHPP41-2000GM_ASDAN54031240AV5V";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              start = "1M";
              end = "128M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];

                subvolumes = {
                  "/root" = {
                    mountpoint = "/";
                  };
                  "/home" = {
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                    mountpoint = "/home";
                  };
                  "/home/${config.me.username}" = { };
                  "/nix" = {
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                    mountpoint = "/nix";
                  };
                  "/persist" = {
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                    mountpoint = "/persist";
                  };
                  "/swap" = {
                    mountpoint = "/.swapvol";
                    swap = {
                      swapfile.size = "20M";
                      swapfile2.size = "20M";
                      swapfile2.path = "rel-path";
                    };
                  };
                };

                mountpoint = "/partition-root";
                swap = {
                  swapfile = {
                    size = "20M";
                  };
                  swapfile1 = {
                    size = "20M";
                  };
                };
              };
            };
          };
        };
      };
    };
  };

  fileSystems."/persist".neededForBoot = true;
}
