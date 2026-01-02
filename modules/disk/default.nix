{ inputs, ... }:
{
  flake.modules.nixos = {
    default = {
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
                subvolumes =
                  let
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  in
                  {
                    "/nix" = {
                      mountpoint = "/nix";
                      inherit mountOptions;
                    };
                    "/persist" = {
                      mountpoint = "/persist";
                      inherit mountOptions;
                    };
                    "/swap" = {
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
    };
    pc = {
      disko.devices.disk.main.content.partitions.ESP = {
        start = "1M";
        end = "500M";
      };
    };
    apple-silicon =
      { config, ... }:
      {
        # https://github.com/nix-community/disko/issues/1125#issuecomment-3427875095
        assertions =
          map
            (p: [
              {
                assertion = config.disko.devices.disk.main.content.partitions.${p}.uuid != null;
                message = "Partition \"${p}\" must have its UUID manually assigned.";
              }
            ])
            [
              "iBootSystemContainer"
              "Container"
              "NixOSContainer"
              "ESP"
              "RecoveryOSContainer"
            ];

        disko.devices.disk.main.content.partitions = {
          iBootSystemContainer = {
            label = "iBootSystemContainer";
            priority = 1;
            type = "AF0B";
          };

          Container = {
            label = "Container";
            priority = 2;
            type = "AF0A";
          };

          NixOSContainer = {
            label = "NixOSContainer";
            priority = 3;
            type = "AF0A";
          };

          ESP.priority = 4;

          RecoveryOSContainer = {
            label = "RecoveryOSContainer";
            priority = 5;
            type = "AF0C";
          };
        };
      };
  };
}
