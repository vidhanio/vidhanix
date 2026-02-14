{ inputs, ... }:
{
  flake-file.inputs.disko.url = "github:nix-community/disko";

  flake.modules.nixos = {
    default =
      { config, ... }:
      {
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
                      nix = {
                        mountpoint = "/nix";
                        inherit mountOptions;
                      };
                      persist = {
                        mountpoint = config.persist.persistentStoragePath;
                        inherit mountOptions;
                      };
                    };
                };
              };
            };
          };
        };
      };
    desktop = {
      disko.devices.disk.main.content.partitions.ESP = {
        start = "1M";
        end = "500M";
      };
    };
    macbook =
      { config, ... }:
      {
        # https://github.com/nix-community/disko/issues/1125#issuecomment-3427875095
        assertions =
          map
            (p: {
              assertion = config.disko.devices.disk.main.content.partitions.${p}.uuid != null;
              message = "Partition \"${p}\" must have its UUID manually assigned.";
            })
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

  configurations = {
    vidhan-pc.module = {
      disko.devices.disk.main.device = "/dev/disk/by-id/nvme-SHPP41-2000GM_ASDAN54031240AV5V";
    };
    vidhan-macbook.module = {
      disko.devices.disk.main = {
        device = "/dev/disk/by-id/nvme-APPLE_SSD_AP0256Q_0ba012e404080419";

        content.partitions = {
          iBootSystemContainer.uuid = "62132ea7-731c-44eb-848a-80a899f51311";
          Container.uuid = "b45447e2-9e71-469e-9601-d4364bdfb492";
          NixOSContainer.uuid = "37fe6b82-8e1a-4271-9192-d267ce78602c";
          ESP.uuid = "42dd4099-5e91-4a89-9c26-f07119130d4a";
          RecoveryOSContainer.uuid = "37b1fd46-dc1b-4342-887c-f533d6ca1de2";
        };
      };
    };
  };
}
