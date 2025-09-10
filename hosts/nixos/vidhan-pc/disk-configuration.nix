{ inputs, lib, ... }:
let
  inherit (inputs) disko impermanence;
in
{
  imports = [
    disko.nixosModules.default
    impermanence.nixosModules.default
  ];

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
    wipe-root.configuration = {
      impermanence.enable = true;
    };
  };

  impermanence = {
    enable = lib.mkDefault false;
    path = "/persist";
    disk = "/dev/disk/by-partlabel/disk-main-root";
    rootSubvolume = "root";
    settings = {
      directories = [
        "/home"
        "/var/log"
        "/var/lib/bluetooth"
        "/var/lib/nixos"
        "/etc/NetworkManager/system-connections"
      ];
      files = [
        "/etc/machine-id"
      ];
    };
  };
}
