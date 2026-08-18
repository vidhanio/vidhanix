{
  inputs,
  lib,
  config,
  ...
}:
let
  cfg = config.configurations;
  usersCfg = config.users;
  inherit ((inputs.flake-aspects.lib lib)) forward;
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
                description = "the user's ssh public key for this host.";
              };
            }) usersCfg;
            publicKey = lib.mkOption {
              type = lib.types.str;
              description = "the public ssh key for this system, which will be added to the authorized keys of all users.";
            };
            module = lib.mkOption {
              type = lib.types.deferredModule;
              default = { };
              description = "nixos configuration module for this configuration.";
            };
          };

          config.module =
            let
              activeUsers = lib.filterAttrs (username: _: config.users.${username}.enable) usersCfg;
              rootPublicKeys = lib.mapAttrsToList (_: c: c.publicKey) cfg;
            in
            { config, ... }:
            {
              options.users.primaryUser = lib.mkOption {
                type = lib.types.enum (lib.attrNames activeUsers);
                default = "vidhanio";
                description = "the primary user of this system.";
              };

              config = {
                networking.hostName = name;

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
