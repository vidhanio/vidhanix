{ self, inputs, ... }:
{
  den.default.nixos = {
    nix.registry = {
      self.flake = self;
      nixpkgs.flake = inputs.nixpkgs;
    };
  };
}
