{ lib, config, ... }:
let
  cfg = config.configurations;
in
{
  options.configurations = lib.mkOption {
    type = lib.types.lazyAttrsOf (
      lib.types.submodule {
        options = name: {
          users = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            description = "List of users on this system, from `options.users`.";
          };
          module = lib.mkOption {
            type = lib.types.deferredModule;
            description = "NixOS configuration module for this configuration.";
          };
        };
      }
    );
  };

  config.flake = {
    nixosConfigurations = lib.mapAttrs (
      name:
      { users, module }:
      let
        userCfgs = lib.getAttrs users config.users;
      in
      lib.nixosSystem {
        modules = [
          config.flake.modules.nixos.default
          module
          {
            networking.hostName = name;

            age.secrets.password.file = ../../secrets/password.age;

            users.users = lib.mapAttrs userCfgs (
              _: user: {
                isNormalUser = true;
                description = user.fullName;
                # TODO: handle seperate passwords per user?
                hashedPasswordFile = config.age.secrets.password.path;
                extraGroups = [ "wheel" ];
              }
            );

            home-manager.users = lib.mapAttrs userCfgs (_: user: user.module);
          }
        ];
      }
    ) cfg;
  };
}
