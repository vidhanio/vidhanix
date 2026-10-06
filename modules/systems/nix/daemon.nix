{ self, inputs, ... }:
{
  profiles.base = {
    module = {
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
