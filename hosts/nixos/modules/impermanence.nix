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

  options.impermanence =
    let
      inherit (lib) mkOption types;
    in
    {
      path = mkOption {
        type = types.str;
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

  config = {
    environment.persistence.${cfg.path} = {
      hideMounts = true;
      inherit (cfg) directories files;
    };

    fileSystems.${cfg.path}.neededForBoot = true;

    security.sudo.extraConfig = ''
      Defaults lecture = never
    '';
  };
}
