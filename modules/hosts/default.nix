{
  inputs,
  lib,
  config,
  ...
}:
let
  inherit (config) hosts users;
in
{
  options.hosts = lib.mkOption {
    description = "Machines and their NixOS and Home Manager configurations.";
    default = { };
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, config, ... }:
        let
          host = config;
          activeUsers = lib.filterAttrs (username: _: host.users.${username}.enable) users;
          activeUsernames = lib.attrNames activeUsers;
        in
        {
          options = {
            users = lib.mapAttrs (username: _: {
              enable = lib.mkEnableOption "${username}'s account";
              publicKey = lib.mkOption {
                type = lib.types.str;
                description = "The user's SSH public key for this host.";
              };
            }) users;
            publicKey = lib.mkOption {
              type = lib.types.str;
              description = "The host's public SSH key, authorized for all users.";
            };
            hostPlatform = lib.mkOption {
              type = lib.types.str;
              description = "The platform for this host.";
            };
            module = lib.mkOption {
              type = lib.types.deferredModule;
              default = { };
              description = "NixOS configuration for this host.";
            };
            homeModule = lib.mkOption {
              type = lib.types.deferredModule;
              default = { };
              description = "Home Manager configuration shared by this host's users.";
            };
          };

          config.module =
            { config, ... }:
            {
              options.users.primaryUser = lib.mkOption {
                type = lib.types.enum ([ "root" ] ++ activeUsernames);
                default =
                  if lib.elem "vidhanio" activeUsernames then
                    "vidhanio"
                  else if activeUsernames == [ ] then
                    "root"
                  else
                    lib.head activeUsernames;
                description = "The primary user of this system.";
              };

              config = {
                networking.hostName = name;
                nixpkgs.hostPlatform = host.hostPlatform;
                system.stateVersion = config.system.nixos.release;

                home-manager = {
                  sharedModules = [ host.homeModule ];
                  users = lib.mapAttrs (_: user: user.module) activeUsers;
                };

                sops.secrets = lib.mapAttrs' (
                  username: _: lib.nameValuePair "passwords/${username}" { neededForUsers = true; }
                ) activeUsers;

                users.users = lib.mapAttrs (username: user: {
                  isNormalUser = true;
                  description = user.fullName;
                  hashedPasswordFile = config.sops.secrets."passwords/${username}".path;
                  extraGroups = [
                    "networkmanager"
                    "wheel"
                  ];
                  useDefaultShell = true;
                }) activeUsers;
              };
            };
        }
      )
    );
  };

  config.flake.nixosConfigurations = lib.mapAttrs (
    _: host: inputs.nixpkgs.lib.nixosSystem { modules = [ host.module ]; }
  ) hosts;
}
