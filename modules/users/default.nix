{ lib, config, ... }:
let
  inherit (config) hosts;
in
{
  options.users = lib.mkOption {
    description = "User identities and their Home Manager configurations.";
    default = { };
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, config, ... }:
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
              default = [ ];
              description = "SSH public keys for the user, including their enabled hosts.";
            };
            face = lib.mkOption {
              type = lib.types.nullOr lib.types.path;
              default = null;
              description = "Path to a PNG image linked to ~/.face.";
            };
            module = lib.mkOption {
              type = lib.types.deferredModule;
              default = { };
              description = "Home Manager configuration for this user.";
            };
          };

          config = {
            publicKeys = lib.mapAttrsToList (_: host: host.users.${name}.publicKey) (
              lib.filterAttrs (_: host: host.users.${name}.enable) hosts
            );
            module.home.file.".face" = lib.mkIf (config.face != null) {
              source = config.face;
            };
          };
        }
      )
    );
  };
}
