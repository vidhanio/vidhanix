{
  lib,
  config,
  ...
}:
let
  hostsCfg = config.hosts;
  flakeUsers = config.users;
in
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
            face = lib.mkOption {
              type = lib.types.nullOr lib.types.path;
              default = null;
              description = "Path to a PNG image to use as the user's face, linked to ~/.face.";
            };
          };

          config = {
            publicKeys = lib.mapAttrsToList (_: c: c.users.${name}.publicKey) (
              lib.filterAttrs (_: c: c.users.${name}.enable) hostsCfg
            );
          };
        }
      )
    );
  };

  config.flake.aspects.face = {
    homeManager =
      { config, ... }:
      let
        face = flakeUsers.${config.home.username}.face;
      in
      {
        home.file.".face" = lib.mkIf (face != null) {
          source = face;
        };
      };
  };
}
