{
  inputs,
  self,
  withSystem,
  ...
}:
{
  profiles.base.module =
    { config, ... }:
    {
      nixpkgs.pkgs = withSystem config.nixpkgs.hostPlatform.system ({ pkgs, ... }: pkgs);
      nix = {
        channel.enable = false;
        settings = {
          auto-optimise-store = true;
          warn-dirty = false;
          allowed-users = [ "@wheel" ];
          trusted-users = [ "@wheel" ];
          accept-flake-config = true;
          extra-experimental-features = [
            "nix-command"
            "flakes"
          ];
        };
        registry = {
          self.flake = self;
          nixpkgs.flake = inputs.nixpkgs;
        };
      };
    };
}
