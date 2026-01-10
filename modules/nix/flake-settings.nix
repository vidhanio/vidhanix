{ config, ... }:
{
  flake.modules.nixos.default = {
    nix.settings = config.flake-file.nixConfig // {
      accept-flake-config = true;
    };
  };
}
