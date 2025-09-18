{
  osConfig,
  config,
  lib,
  inputs,
  ...
}:
let
  osCfg = osConfig.impermanence;
  cfg = config.impermanence;
in
{
  imports = with inputs; [ impermanence.homeManagerModules.default ];

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

  config = lib.mkIf (osConfig ? impermanence) {
    home.persistence."${osCfg.path}" = {
      inherit (cfg) directories files;
    };
  };
}
