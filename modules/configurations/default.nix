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
      lib.types.submodule {
        options = {
          module = lib.mkOption {
            type = lib.types.deferredModule;
            default = { };
            description = "NixOS configuration module for this configuration.";
          };
        };
      }
    );
  };

  config = {
    flake.nixosConfigurations = lib.mapAttrs (
      name:
      { module }:
      inputs.nixpkgs.lib.nixosSystem {
        modules = [
          module
          { networking.hostName = name; }
        ];
      }
    ) cfg;
  };
}
