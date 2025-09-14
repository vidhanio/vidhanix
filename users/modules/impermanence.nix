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

  options =
    let
      inherit (lib) mkOption types;
    in
    {
      impermanence = {
        directories = mkOption {
          type = types.listOf types.str;
          default = [ ];
          description = "Directories in your home directory that you want to link to persistent storage.";
        };

        files = mkOption {
          type = types.listOf types.str;
          default = [ ];
          description = "Files in your home directory that you want to link to persistent storage.";
        };
      };
    };

  config = lib.mkIf (osConfig ? impermanence) {
    home.persistence."${osCfg.path}" = {
      inherit (cfg) directories files;
    };
  };
}
