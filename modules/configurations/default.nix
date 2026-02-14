{
  inputs,
  lib,
  config,
  ...
}:
let
  cfg = config.configurations;
  usersCfg = config.users;
in
{
  options.configurations = lib.mkOption {
    type = lib.types.lazyAttrsOf (
      lib.types.submodule (
        { name, config, ... }:
        {
          options = {
            users = lib.mkOption {
              type = lib.types.listOf (lib.types.enum (lib.attrNames usersCfg));
              description = "A list of users that should be created on the system.";
            };
            publicKey = lib.mkOption {
              type = lib.types.str;
              description = "The public SSH key for this system, which will be added to the authorized keys of all users.";
            };
            module = lib.mkOption {
              type = lib.types.deferredModule;
              default = { };
              description = "NixOS configuration module for this configuration.";
            };
            homeModule = lib.mkOption {
              type = lib.types.deferredModule;
              default = { };
              description = "Home Manager configuration module for this configuration.";
            };
          };

          config.module =
            let
              activeUsers = lib.getAttrs config.users usersCfg;
              inherit (config) homeModule publicKey;
            in
            { config, ... }:
            {
              options.users.primaryUser = lib.mkOption {
                type = lib.types.enum config.users;
                default = "vidhanio";
                description = "The primary user of this system.";
              };

              config = {
                networking.hostName = name;

                age.secrets.password.file = ../../secrets/password.age;

                users.users = lib.mapAttrs (_: user: {
                  isNormalUser = true;
                  description = user.fullName;
                  # TODO: handle seperate passwords per user?
                  hashedPasswordFile = config.age.secrets.password.path;
                  extraGroups = [ "wheel" ];
                  useDefaultShell = true;

                  openssh.authorizedKeys.keys = user.publicKeys ++ [ publicKey ];
                }) activeUsers;

                home-manager = {
                  users = lib.mapAttrs (_: user: user.module) activeUsers;
                  sharedModules = [ homeModule ];
                };
              };
            };
        }
      )
    );
  };

  config = {
    flake.nixosConfigurations = lib.mapAttrs (
      _:
      { module, ... }:
      inputs.nixpkgs.lib.nixosSystem {
        modules = [ module ];
      }
    ) cfg;
  };
}
