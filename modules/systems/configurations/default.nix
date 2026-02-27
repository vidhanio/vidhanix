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
            users = lib.mapAttrs (username: _: {
              enable = lib.mkEnableOption "${username}'s account";
              publicKey = lib.mkOption {
                type = lib.types.str;
                description = "The user's SSH public key for this host.";
              };
            }) usersCfg;
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
              activeUsers = lib.filterAttrs (username: _: config.users.${username}.enable) usersCfg;
              inherit (config) homeModule publicKey;
            in
            { config, ... }:
            {
              options.users.primaryUser = lib.mkOption {
                type = lib.types.enum (lib.attrNames activeUsers);
                default = "vidhanio";
                description = "The primary user of this system.";
              };

              config = {
                networking.hostName = name;

                age.secrets.password.file = ../../../secrets/password.age;

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

    flake.modules.nixos.default = {
      programs.ssh.knownHosts = lib.mapAttrs (
        hostname:
        { publicKey, ... }:
        {
          inherit publicKey;
          extraHostNames = [ "${hostname}.local" ];
        }
      ) cfg;
    };
  };
}
