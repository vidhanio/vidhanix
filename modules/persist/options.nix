{ inputs, lib, ... }:
let
  options = {
    path = lib.mkOption {
      type = lib.types.str;
      default = "/persist";
      description = "The path where persistent data is stored.";
      readOnly = true;
    };
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
  # https://github.com/nix-community/impermanence/pull/272
  # https://github.com/nix-community/impermanence/pull/243
  flake-file.inputs.impermanence.url = "github:vidhanio/impermanence/hmv2-trash";

  flake.modules = {
    nixos.default =
      { config, ... }:
      let
        cfg = config.persist;
      in
      {
        imports = [
          inputs.impermanence.nixosModules.default
        ];

        options.persist = options;

        config = {
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

          environment.persistence.${cfg.path} = {
            hideMounts = true;
            allowTrash = true;

            inherit (cfg) directories files;
          };

          fileSystems.${cfg.path}.neededForBoot = true;
        };
      };
    homeManager.default =
      { config, ... }:
      let
        cfg = config.persist;
      in
      {
        imports = [
          inputs.impermanence.homeManagerModules.default
        ];

        options.persist = options;

        config = {
          home.persistence.${cfg.path} = {
            hideMounts = true;
            allowTrash = true;

            inherit (cfg) directories files;
          };
        };
      };
  };
}
