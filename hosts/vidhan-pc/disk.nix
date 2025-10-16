{
  disko.devices = {
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "size=8G"
        "defaults"
        "mode=755"
      ];
    };

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

                subvolumes =
                  let
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  in
                  {
                    "/nix" = {
                      inherit mountOptions;
                      mountpoint = "/nix";
                    };
                    "/persist" = {
                      inherit mountOptions;
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

  impermanence.enable = true;
}
