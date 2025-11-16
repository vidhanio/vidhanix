{
  config,
  lib,
  ...
}:
let
  cfg = config.persist;
in
{
  options.persist =
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
    };

  config = lib.mkMerge [
    {
      persist = {
        directories = [
          "/var/log"
          "/var/lib/bluetooth"
          "/var/lib/nixos"
        ];
        files = [
          "/etc/machine-id"
        ];
      };
    }
    (lib.mkIf cfg.enable {
      environment.persistence.${cfg.path} = {
        hideMounts = true;
        allowTrash = true;

        inherit (cfg) directories files;
      };

      fileSystems.${cfg.path}.neededForBoot = true;

      security.sudo.extraConfig = ''
        Defaults lecture = never
      '';
    })
  ];
}
