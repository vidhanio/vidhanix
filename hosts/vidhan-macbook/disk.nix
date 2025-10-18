{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";

        destroy = false;

        content = {
          type = "gpt";
          partitions = {
            iBootSystemContainer = {
              label = "iBootSystemContainer";
              priority = 1;
              type = "AF0B";
              device = "/dev/nvme0n1p1";
            };

            macOSContainer = {
              label = "macOSContainer";
              priority = 2;
              type = "AF0A";
              device = "/dev/nvme0n1p2";
            };

            NixOSContainer = {
              label = "NixOSContainer";
              priority = 3;
              type = "AF0A";
              device = "/dev/nvme0n1p3";
            };

            ESP = {
              priority = 4;
              type = "EF00";
              device = "/dev/nvme0n1p4";

              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "fmask=0022"
                  "dmask=0022"
                ];
              };
            };

            root = {
              priority = 5;
              device = "/dev/nvme0n1p5";

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
                    "/root" = {
                      inherit mountOptions;
                      mountpoint = "/";
                    };
                    "/nix" = {
                      inherit mountOptions;
                      mountpoint = "/nix";
                    };
                    "/persist" = {
                      inherit mountOptions;
                      mountpoint = "/persist";
                    };
                    "/swap" = {
                      mountpoint = "/swap";
                      swap.swapfile.size = "16G";
                    };
                  };
              };
            };

            RecoveryOSContainer = {
              label = "RecoveryOSContainer";
              priority = 6;
              type = "AF0C";
              device = "/dev/nvme0n1p6";
            };
          };
        };
      };
    };
  };

  # fileSystems."/" = {
  #   device = "/dev/disk/by-uuid/c78b6116-9354-4afb-98bd-e6a8fae337c2";
  #   fsType = "ext4";
  # };

  # fileSystems."/boot" = {
  #   device = "/dev/disk/by-uuid/7387-1B07";
  #   fsType = "vfat";
  #   options = [
  #     "fmask=0022"
  #     "dmask=0022"
  #   ];
  # };
}
