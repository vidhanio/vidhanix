{
  config,
  inputs,
  self,
  withSystem,
  ...
}:
let
  flakeConfig = config.flake-file.nixConfig;
in
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
          inherit (flakeConfig)
            extra-substituters
            extra-trusted-public-keys
            extra-experimental-features
            ;
        };
        registry = {
          self.flake = self;
          nixpkgs.flake = inputs.nixpkgs;
        };
      };
    };
}
