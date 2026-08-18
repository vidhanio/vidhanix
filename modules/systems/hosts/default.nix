{
  inputs,
  lib,
  config,
  ...
}:
let
  cfg = config.hosts;
  usersCfg = config.users;
  inherit ((inputs.flake-aspects.lib lib)) forward;
in
{
  options.hosts = lib.mkOption {
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
            hostPlatform = lib.mkOption {
              type = lib.types.str;
              description = "The platform for this host.";
            };
            module = lib.mkOption {
              type = lib.types.deferredModule;
              default = { };
              description = "NixOS configuration module for this host.";
            };
          };

          config.module =
            let
              activeUsers = lib.filterAttrs (username: _: config.users.${username}.enable) usersCfg;
              rootPublicKeys = lib.mapAttrsToList (_: c: c.publicKey) cfg;
              inherit (config) hostPlatform;
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
                nixpkgs.hostPlatform = hostPlatform;

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
                  openssh.authorizedKeys.keys = user.publicKeys ++ rootPublicKeys;
                }) activeUsers;
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
      inputs.nixpkgs.lib.nixosSystem { modules = [ module ]; }
    ) cfg;

    flake.aspects =
      { aspects, ... }:
      lib.mapAttrs (
        _:
        { users, ... }:
        forward {
          each = lib.attrNames (lib.filterAttrs (_: user: user.enable) users);
          fromClass = _: "homeManager";
          intoClass = _: "nixos";
          intoPath = username: [
            "home-manager"
            "users"
            username
          ];
          fromAspect = username: aspects.${username};
        }
      ) cfg;
  };
}
