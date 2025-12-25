{ lib, config, ... }:
let
  cfg = config.users;
in
{
  options.users = lib.mkOption {
    type = lib.types.attrsOf lib.types.submodule {
      options = name: {
        fullName = lib.mkOption {
          type = lib.types.str;
          description = "The full name of the user.";
        };
        email = lib.mkOption {
          type = lib.types.str;
          description = "The email address of the user.";
        };
        module = lib.mkOption {
          type = lib.types.deferredModule;
          description = "Home Manager configuration for the user.";
        };
      };
    };
  };

  config.flake.modules.nixos.default = nixos: {
    age.secrets.password.file = ../../secrets/password.age;

    users.users = lib.mapAttrs cfg (
      _: user: {
        enable = lib.mkDefault false;
        isNormalUser = true;
        description = user.fullName;
        # TODO: handle seperate passwords per user?
        hashedPasswordFile = config.age.secrets.password.path;
        extraGroups = [ "wheel" ];
        useDefaultShell = true;
      }
    );

    home-manager.users =
      let
        activeUserNames = lib.attrNames (
          lib.filterAttrs (_: user: user.enable && user.isNormalUser) nixos.users.users
        );
        activeUsers = lib.getAttrs activeUserNames cfg;
      in
      lib.mapAttrs activeUsers (_: user: user.module);
  };
}
