{ self, inputs, ... }:
{
  flake.aspects.nix = {
    nixos = {
      nix = {
        channel.enable = false;

        settings = {
          warn-dirty = false;
          allowed-users = [ "@wheel" ];
          trusted-users = [ "@wheel" ];
        };

        optimise.automatic = true;

        registry = {
          self.flake = self;
          nixpkgs.flake = inputs.nixpkgs;
        };
      };
    };
  };
}
