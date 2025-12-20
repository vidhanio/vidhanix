{
  inputs,
  lib,
  config,
  ...
}:
let
  cfg = config.configurations;
in
{
  options.configurations = lib.mkOption {
    type = lib.types.lazyAttrsOf (
      lib.types.submodule (
        { name, config, ... }:
        {
          options = {
            system = lib.mkOption {
              type = lib.types.str;
              description = "The system architecture for this configuration.";
            };
            stateVersion = lib.mkOption {
              type = lib.types.str;
              description = "The NixOS state version for this configuration.";
            };
            module = lib.mkOption {
              type = lib.types.deferredModule;
              default = { };
              description = "NixOS configuration module for this configuration.";
            };
          };

          config = {
            module = {
              networking.hostName = name;
              nixpkgs.hostPlatform = config.system;
              system.stateVersion = config.stateVersion;
            };
          };
        }
      )
    );
  };

  config = {
    flake.nixosConfigurations = lib.mapAttrs (
      _name:
      { module, ... }:
      inputs.nixpkgs.lib.nixosSystem {
        modules = [ module ];
      }
    ) cfg;
  };
}
