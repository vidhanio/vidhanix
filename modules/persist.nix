{
  lib,
  ...
}:
let
  sharedOptions = {
    directories = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Directories that you want to persist.";
    };
    files = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Files that you want to persist.";
    };
  };
in
{
  flake.modules = {
    nixos.default =
      args:
      let
        cfg = args.config.persist;
      in
      {
        options.persist = sharedOptions // {
          enable = lib.mkEnableOption "persisting specified files and directories";
          path = lib.mkOption {
            type = lib.types.str;
            default = "/persist";
            description = "The path where persisted data will be stored.";
          };
        };

        config = lib.mkMerge [
          {
            persist = {
              directories = [
                "/var/log"
                "/var/lib/nixos"
                "/var/tmp"
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
      };
    homeManager.default =
      args:
      let
        osCfg = args.osConfig.persist;
        cfg = args.config.persist;
      in
      {
        options.persist = sharedOptions;

        config = {
          home.persistence."${osCfg.path}" = {
            inherit (osCfg) enable;
            inherit (args.osConfig.environment.persistence."${osCfg.path}") hideMounts allowTrash;
            inherit (cfg) directories files;
          };
        };
      };
  };
}
