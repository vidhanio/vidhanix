{ lib, config, ... }:
let
  cfg = config.configurations;
in
{
  options.configurations = lib.mkOption {
    type = lib.types.lazyAttrsOf (
      lib.types.submodule {
        options = name: {
          module = lib.mkOption {
            type = lib.types.deferredModule;
            description = "NixOS configuration module for this hostname.";
          };
        };
      }
    );
  };

  config.flake = {
    nixosConfigurations = lib.mapAttrs (
      name: module:
      lib.nixosSystem {
        modules = [
          config.flake.modules.nixos.default
          { networking.hostName = name; }
          module
        ];
      }
    ) cfg;
  };
}
