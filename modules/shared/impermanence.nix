{
  _class,
  config,
  lib,
  inputs,
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

  config = lib.mkIf cfg.enable (
    lib.optionalAttrs (_class == "nixos") {
      environment.persistence.${cfg.path} = {
        hideMounts = true;
        inherit (cfg) directories files;
      };

      fileSystems.${cfg.path}.neededForBoot = true;

      security.sudo.extraConfig = ''
        Defaults lecture = never
      '';

      home-manager.sharedModules = with inputs; [ impermanence.homeManagerModules.default ];
    }
  );
}
