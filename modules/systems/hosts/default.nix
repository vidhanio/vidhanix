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
      lib.types.submodule {
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
        };
      }
    );
  };

  config = {
    flake.nixosConfigurations = lib.mapAttrs (
      name: _: inputs.nixpkgs.lib.nixosSystem { modules = [ inputs.self.modules.nixos.${name} ]; }
    ) cfg;

    flake.aspects =
      { aspects, ... }:
      lib.mapAttrs (
        name:
        { users, hostPlatform, ... }:
        let
          activeUsers = lib.filterAttrs (username: _: users.${username}.enable) usersCfg;
          activeUsernames = lib.attrNames activeUsers;
        in
        {
          includes = [
            (forward {
              each = activeUsernames;
              fromClass = _: "homeManager";
              intoClass = _: "nixos";
              intoPath = username: [
                "home-manager"
                "users"
                username
              ];
              fromAspect = username: aspects.${username};
            })
          ];

          nixos =
            { config, ... }:
            {
              options.users.primaryUser = lib.mkOption {
                type = lib.types.enum activeUsernames;
                default = "vidhanio";
                description = "The primary user of this system.";
              };

              config = {
                networking.hostName = name;
                nixpkgs.hostPlatform = hostPlatform;
                system.stateVersion = config.system.nixos.release;

                home-manager.sharedModules = [
                  inputs.self.modules.homeManager.${name}
                ];

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

          homeManager = { };
        }
      ) cfg;
  };
}
