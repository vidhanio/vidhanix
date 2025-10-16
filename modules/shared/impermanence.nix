{
  _class,
  options,
  config,
  lib,
  ...
}:
let
  cfg = config.impermanence;
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
    };

  config = lib.optionalAttrs (options ? environment.persistence) (
    lib.mkMerge [
      {
        environment.persistence.${cfg.path} = {
          inherit (cfg) enable;
          hideMounts = true;
          allowTrash = true;

          inherit (cfg) directories files;
        };
      }
      (lib.mkIf cfg.enable {
        fileSystems.${cfg.path}.neededForBoot = true;

        security.sudo.extraConfig = ''
          Defaults lecture = never
        '';
      })
    ]
  );
}
