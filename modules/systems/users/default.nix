{ lib, config, ... }:
{
  options.users = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, ... }:
        {
          options = {
            fullName = lib.mkOption {
              type = lib.types.str;
              description = "The full name of the user.";
            };
            email = lib.mkOption {
              type = lib.types.str;
              description = "The email address of the user.";
            };
            publicKeys = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              description = "A list of SSH public keys for the user.";
            };
            module = lib.mkOption {
              type = lib.types.deferredModule;
              default = { };
              description = "Home Manager configuration for the user.";
            };
          };

          config = {
            publicKeys = lib.mapAttrsToList (_: c: c.users.${name}.publicKey) (
              lib.filterAttrs (_: c: c.users.${name}.enable) config.configurations
            );
          };
        }
      )
    );
  };
}
