{ self, inputs, ... }:
{
  flake.aspects.nix = {
    nixos = {
      nix = {
        channel.enable = false;

        settings = {
          auto-optimise-store = true;
          warn-dirty = false;
          allowed-users = [ "@wheel" ];
          trusted-users = [ "@wheel" ];
        };
        registry = {
          self.flake = self;
          nixpkgs.flake = inputs.nixpkgs;
        };
      };
    };
  };
}
