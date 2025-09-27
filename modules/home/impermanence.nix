{
  osConfig,
  config,
  lib,
  ...
}:
let
  osCfg = osConfig.impermanence;
  cfg = config.impermanence;
in
{
  options.impermanence =
    let
      inherit (lib) mkOption types;
    in
    {
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

  config = lib.mkIf osCfg.enable {
    home.persistence."${osCfg.path}" = {
      hideMounts = osConfig.environment.persistence."${osCfg.path}".hideMounts;
      inherit (cfg) directories files;
    };
  };
}
