{ inputs, lib, ... }:
let
  path = "/persist";
  options = {
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

          environment.persistence.${path} = {
            hideMounts = true;
            allowTrash = true;

            inherit (cfg) directories files;
          };

          fileSystems.${path}.neededForBoot = true;
        };
      };
    homeManager.default =
      { config, osConfig, ... }:
      let
        cfg = config.persist;
      in
      {
        imports = [
          inputs.impermanence.homeManagerModules.default
        ];

        options.persist = options;

        config = {
          home.persistence.${path} = {
            hideMounts = true;
            allowTrash = true;

            inherit (cfg) directories files;
          };
        };
      };
  };
}
