{ lib, ... }:
{
  options.profiles = lib.mkOption {
    description = "Configurations shared by a class of machines.";
    default = { };
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          module = lib.mkOption {
            type = lib.types.deferredModule;
            default = { };
            description = "NixOS configuration for this profile.";
          };
          homeModule = lib.mkOption {
            type = lib.types.deferredModule;
            default = { };
            description = "Home Manager configuration for this profile.";
          };
        };
      }
    );
  };
}
