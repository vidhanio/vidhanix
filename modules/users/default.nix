{ lib, ... }:
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
}
