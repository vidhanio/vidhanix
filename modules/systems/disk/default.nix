{ inputs, ... }:
{
  flake-file.inputs.disko.url = "github:vidhanio/disko/feature/skip-partition-uuid";

  flake.aspects.disk = {
    nixos =
      { ... }:
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
                    };
                };
              };
            };
          };
        };
      };

    provides = {
      desktop.nixos = {
        disko.devices.disk.main.content.partitions.ESP = {
          start = "1M";
          end = "500M";
        };
      };

      apple-silicon.nixos = {
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
  };
}
