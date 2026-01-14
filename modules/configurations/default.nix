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

          config.module = {
            networking.hostName = name;
            home-manager.sharedModules = [ config.homeModule ];
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
  };
}
