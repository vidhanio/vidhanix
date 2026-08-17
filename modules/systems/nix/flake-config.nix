{ config, ... }:
{
  flake.aspects.nix.nixos = {
    nix.settings = {
      accept-flake-config = true;
      inherit (config.flake-file.nixConfig)
        extra-substituters
        extra-trusted-public-keys
        extra-experimental-features
        ;
    };
  };
}
