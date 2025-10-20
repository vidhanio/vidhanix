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
              type = "AF0B";
              uuid = "174510dd-4f09-4210-b777-c6704b547835";
              start = "6s";
              end = "128005s";
            };

            Container = {
              label = "Container";
              type = "AF0A";
              uuid = "a2b24943-af07-4577-ab01-1a608662946e";
              start = "128006s";
              end = "16762629s";
            };

            NixOSContainer = {
              label = "NixOSContainer";
              type = "AF0A";
              uuid = "abff7d6b-ce0a-4544-9f95-3107ae3f9b61";
              start = "16762630s";
              end = "17372933s";
            };

            ESP = {
              type = "EF00";
              uuid = "24e999b2-7fa5-49a6-b4c1-83010039a359";
              start = "17372934s";
              end = "17495045s";

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
              type = "AF0C";
              uuid = "a91a89f1-ca9d-4dfb-b3c3-a1d389d612ac";
              start = "59968630s";
              end = "61279338s";
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
