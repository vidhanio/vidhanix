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
        { name, ... }:
        {
          options.module = lib.mkOption {
            type = lib.types.deferredModule;
            default = { };
            description = "NixOS configuration module for this configuration.";
          };

          config.module = {
            networking.hostName = name;
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
