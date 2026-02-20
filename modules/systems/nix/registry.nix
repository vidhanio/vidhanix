{ self, inputs, ... }:
{
  flake.modules.nixos.default = {
    nix.registry = {
      self.flake = self;
      nixpkgs.flake = inputs.nixpkgs;
    };
  };
}
