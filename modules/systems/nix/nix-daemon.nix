{ self, inputs, ... }:
{
  flake.modules.nixos.default = {
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
}
