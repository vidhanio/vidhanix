{ config, lib, ... }:
let
  inherit (lib) mkOption mkEnableOption types;
  cfg = config.impermanence;
in
{
  options = {
    impermanence = {
      enable = mkEnableOption "impermanence";
      path = mkOption {
        type = with types; str;
        description = "The path where persisted data will be stored.";
      };
      disk = mkOption {
        type = with types; str;
        description = "The disk in which the root filesystem is stored.";
      };
      rootSubvolume = mkOption {
        type = with types; str;
        default = "root";
        description = "The name of the root subvolume.";
      };
      settings = mkOption {
        type = with types; attrs;
        default = { };
        description = "Settings to pass to impermanence.";
      };
    };

  };

  config = {
    boot.initrd.postResumeCommands = lib.mkIf cfg.enable (
      lib.mkAfter ''
        mkdir /btrfs_tmp
        mount '${cfg.disk}' /btrfs_tmp
        if [[ -e '/btrfs_tmp/${cfg.rootSubvolume}' ]]; then
            mkdir -p /btrfs_tmp/old_roots
            timestamp=$(date --date="@$(stat -c %Y '/btrfs_tmp/${cfg.rootSubvolume}')" "+%Y-%m-%-d_%H:%M:%S")
            mv '/btrfs_tmp/${cfg.rootSubvolume}' "/btrfs_tmp/old_roots/$timestamp"
        fi

        delete_subvolume_recursively() {
            IFS=$'\n'
            for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
                delete_subvolume_recursively "/btrfs_tmp/$i"
            done
            btrfs subvolume delete "$1"
        }

        for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
            delete_subvolume_recursively "$i"
        done

        btrfs subvolume create '/btrfs_tmp/${cfg.rootSubvolume}'
        umount /btrfs_tmp
      ''
    );

    environment.persistence.${cfg.path} = cfg.settings // {
      hideMounts = true;
    };

    fileSystems.${cfg.path}.neededForBoot = true;
  };
}
