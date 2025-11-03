{
  osConfig,
  config,
  lib,
  ...
}:
let
  osCfg = osConfig.persist;
  cfg = config.persist;
in
{
  options.persist =
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

  config = {
    home.persistence."${osCfg.path}" = {
      inherit (osCfg) enable;
      inherit (osConfig.environment.persistence."${osCfg.path}") hideMounts allowTrash;
      inherit (cfg) directories files;
    };
  };
}
