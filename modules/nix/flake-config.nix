{ config, ... }:
{
  flake.modules.nixos.default = {
    nix.settings = {
      accept-flake-config = true;
      inherit (config.flake-file.nixConfig) extra-substituters extra-trusted-public-keys;
    };
  };
}
