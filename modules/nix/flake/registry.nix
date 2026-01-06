{ self, ... }:
{
  flake.modules.nixos.default = {
    nix.registry.self.flake = self;
  };
}
