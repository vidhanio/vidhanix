{ inputs, ... }:
{
  flake-file.inputs.disko.url = "github:vidhanio/disko/feature/skip-partition-uuid";

  profiles.base.module = {
    imports = [ inputs.disko.nixosModules.default ];
    disko.devices.disk.main = {
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
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
                nix = {
                  mountpoint = "/nix";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
                swap = {
                  mountpoint = "/swap";
                  swap.swapfile.size = "16G";
                };
              };
            };
          };
        };
      };
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
