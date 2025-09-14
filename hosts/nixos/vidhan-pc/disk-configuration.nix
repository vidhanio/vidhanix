{ inputs, lib, ... }:
{
  imports = with inputs; [ disko.nixosModules.default ] ++ [ ../modules/impermanence.nix ];

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
                };
              };
            };
          };
        };
      };
    };
  };

  specialisation = {
    wipe.configuration = {
      impermanence.wipe.enable = true;
    };
  };

  impermanence = {
    wipe.enable = lib.mkDefault true;
    path = "/persist";
    disk = "/dev/disk/by-partlabel/disk-main-root";
  };
}
