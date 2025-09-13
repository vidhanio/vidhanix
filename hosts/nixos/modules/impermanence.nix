{
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.impermanence;
in
{
  imports = with inputs; [ impermanence.nixosModules.default ];

  options =
    let
      inherit (lib) mkOption mkEnableOption types;
    in
    {
      impermanence = {
        enable = mkEnableOption "impermanence";
        path = mkOption {
          type = types.str;
          description = "The path where persisted data will be stored.";
        };
        disk = mkOption {
          type = types.str;
          description = "The disk in which the root filesystem is stored.";
        };
        rootSubvolume = mkOption {
          type = types.str;
          default = "root";
          description = "The name of the root subvolume.";
        };
        directories = mkOption {
          type = types.listOf types.str;
          default = [ ];
          description = "Directories that you want to link to persistent storage.";
        };
        files = mkOption {
          type = types.listOf types.str;
          default = [ ];
          description = "Files that you want to link to persistent storage.";
        };
      };
    };

  config = {
    boot.initrd.postResumeCommands = lib.mkIf cfg.enable (
      lib.mkAfter ''
        mkdir -p /mnt
        mount -o user_subvol_rm_allowed '${cfg.disk}' /mnt

        mkdir -p /mnt/snapshots
        timestamp=$(date --date="@$(stat -c %Y /mnt/root/)" -Iseconds)
        btrfs subvolume snapshot -r '/mnt/${cfg.rootSubvolume}' /mnt/snapshots/$timestamp

        btrfs subvolume delete -R '/mnt/${cfg.rootSubvolume}'
        btrfs subvolume create '/mnt/${cfg.rootSubvolume}'

        for snapshot in $(find /mnt/snapshots -maxdepth 1 -mtime +7); do
          btrfs subvolume delete -R $snapshot
        done

        umount /mnt
      ''
    );

    environment.persistence.${cfg.path} = {
      hideMounts = true;
      inherit (cfg) directories files;
    };

    programs.fuse.userAllowOther = true;

    fileSystems.${cfg.path}.neededForBoot = true;
  };
}
