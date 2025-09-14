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
        wipe.enable = mkEnableOption "data wipe on boot";
        path = mkOption {
          type = types.str;
          description = "The path where persisted data will be stored.";
        };
        disk = mkOption {
          type = types.str;
          description = "The disk in which the root filesystem is stored.";
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
    environment.persistence.${cfg.path} = {
      hideMounts = true;
      inherit (cfg) directories files;
    };

    programs.fuse.userAllowOther = true;

    fileSystems.${cfg.path}.neededForBoot = true;
  };
}
