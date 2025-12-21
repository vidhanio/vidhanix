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
        githubUsername = lib.mkOption {
          type = lib.types.str;
          description = "The GitHub username of the user.";
        };
        module = lib.mkOption {
          type = lib.types.deferredModule;
          description = "Home Manager configuration for the user.";
        };
      };
    };
  };

  config.flake.modules = {
    nixos.default = nixos: {
      age.secrets.password.file = ../secrets/password.age;

      users = {
        mutableUsers = false;
        users = lib.mapAttrs (_: userCfg: {
          description = userCfg.fullName;
          # TODO: handle seperate passwords per user?
          hashedPasswordFile = nixos.config.age.secrets.password.path;
          isNormalUser = true;
          extraGroups = [ "wheel" ];
        }) cfg;
      };
    };
  };
}
