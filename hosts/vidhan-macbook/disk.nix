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
              uuid = "62132ea7-731c-44eb-848a-80a899f51311";
            };

            Container = {
              label = "Container";
              priority = 2;
              type = "AF0A";
              uuid = "18fa4f40-f0b2-407f-9eea-a1491cefeaa4";
            };

            NixOSContainer = {
              priority = 3;
              type = "AF0A";
              uuid = "4238759e-8d52-4fd7-a67f-c1476fce03f9";
            };

            ESP = {
              priority = 4;
              type = "EF00";
              uuid = "ff9579f2-e598-4e95-b8be-91f66eaba3a4";

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
              priority = 5;
              type = "AF0C";
              uuid = "37b1fd46-dc1b-4342-887c-f533d6ca1de2";
            };
          };
        };
      };
    };
  };
}
