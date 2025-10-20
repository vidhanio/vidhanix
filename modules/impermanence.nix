{
  config,
  lib,
  ...
}:
let
  cfg = config.impermanence;
  rootCfg = config.fileSystems."/";
in
{
  options.impermanence =
    let
      inherit (lib) mkEnableOption mkOption types;
    in
    {
      enable = mkEnableOption "impermanence";
      path = mkOption {
        type = types.str;
        default = "/persist";
        description = "The path where persisted data will be stored.";
      };
      directories = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Directories that you want to persist.";
      };
      files = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Files that you want to persist.";
      };
      btrfs = {
        wipe = mkOption {
          type = types.bool;
          default = true;
          description = "Wipe BTRFS root subvolume on boot (only if root is BTRFS).";
        };

        rootSubvolume = mkOption {
          type = types.str;
          default = "/root";
          description = "The BTRFS root subvolume.";
        };
      };
    };

  config = lib.mkIf cfg.enable {
    environment.persistence.${cfg.path} = {
      hideMounts = true;
      allowTrash = true;

      inherit (cfg) directories files;
    };

    fileSystems.${cfg.path}.neededForBoot = true;

    security.sudo.extraConfig = ''
      Defaults lecture = never
    '';

    boot.initrd.systemd = lib.mkIf (cfg.btrfs.wipe && rootCfg.fsType == "btrfs") {
      enable = true;

      services.wipe-root =
        let
          deviceService =
            if lib.hasPrefix "/" rootCfg.device then
              let
                stripped = lib.removePrefix "/" rootCfg.device;
                escaped = lib.strings.escapeC [ "-" ] stripped;
                dashed = lib.replaceString "/" "-" escaped;
              in
              "${dashed}.device"
            else
              throw "impermanence: root device \"${rootCfg.device}\" must begin with /";

        in
        {
          description = "Wipe BTRFS root subvolume on boot";

          requires = [ deviceService ];
          wantedBy = [ "initrd.target" ];

          after = [ deviceService ];
          before = [ "sysroot.mount" ];

          unitConfig.DefaultDependencies = "no";
          serviceConfig.Type = "oneshot";

          script = ''
            mkdir -p /tmp
            MNTPOINT=$(mktemp -d)
            mount '${rootCfg.device}' "$MNTPOINT"
            trap 'umount "$MNTPOINT"; rm -rf "$MNTPOINT"' EXIT
            btrfs subvolume delete -R "$MNTPOINT"/'${cfg.btrfs.rootSubvolume}'
            btrfs subvolume create "$MNTPOINT"/'/${cfg.btrfs.rootSubvolume}'
          '';
        };
    };
  };
}
