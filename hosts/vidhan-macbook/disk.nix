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
              uuid = "7f28fe23-37e9-4d77-80e9-7e9a1851ce4c";
            };

            macOSContainer = {
              label = "macOSContainer";
              priority = 2;
              type = "AF0A";
              uuid = "472ca1d5-7ae2-40a5-bab8-bd2843387e1e";
            };

            NixOSContainer = {
              label = "NixOSContainer";
              priority = 3;
              type = "AF0A";
              uuid = "98e46bbd-97fb-4e58-8bec-4e350e4409e2";
            };

            ESP = {
              priority = 4;
              type = "EF00";
              uuid = "6383c35f-4241-4dda-b6f9-f662cdb81141";

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
              uuid = "3dfb4d81-0d88-473a-81a0-57088bfa54bd";
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
