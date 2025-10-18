{
  # disko.devices = {
  #   disk = {
  #     main = {
  #       type = "disk";
  #       device = "/dev/nvme0n1";

  #       destroy = false;

  #       content = {
  #         type = "gpt";
  #         partitions = {
  #           iBootSystemContainer = {
  #             type = "AF0B";
  #             device = "/dev/nvme0n1p1";
  #           };

  #           macOSContainer = {
  #             type = "AF0A";
  #             device = "/dev/nvme0n1p2";
  #           };

  #           NixOSContainer = {
  #             type = "AF0A";
  #             device = "/dev/nvme0n1p3";
  #           };

  #           ESP = {
  #             type = "EF00";
  #             device = "/dev/nvme0n1p4";

  #             priority = 1;

  #             content = {
  #               type = "filesystem";
  #               format = "vfat";
  #               mountpoint = "/boot";
  #               mountOptions = [
  #                 "fmask=0022"
  #                 "dmask=0022"
  #               ];
  #             };
  #           };

  #           root = {
  #             type = "8300";
  #             device = "/dev/nvme0n1p5";

  #             content = {
  #               type = "btrfs";
  #               extraArgs = [ "-f" ];

  #               subvolumes =
  #                 let
  #                   mountOptions = [
  #                     "compress=zstd"
  #                     "noatime"
  #                   ];
  #                 in
  #                 {
  #                   "/root" = {
  #                     inherit mountOptions;
  #                     mountpoint = "/";
  #                   };
  #                   "/nix" = {
  #                     inherit mountOptions;
  #                     mountpoint = "/nix";
  #                   };
  #                   "/persist" = {
  #                     inherit mountOptions;
  #                     mountpoint = "/persist";
  #                   };
  #                 };
  #             };
  #           };

  #           RecoveryOSContainer = {
  #             type = "AF0C";
  #             device = "/dev/nvme0n1p6";
  #           };
  #         };
  #       };
  #     };
  #   };
  # };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/c78b6116-9354-4afb-98bd-e6a8fae337c2";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/7387-1B07";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };
}
