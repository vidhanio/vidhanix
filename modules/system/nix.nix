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
      sops.secrets.netrc = { };
      nix = {
        channel.enable = false;
        settings = {
          netrc-file = config.sops.secrets.netrc.path;
          auto-optimise-store = true;
          warn-dirty = false;
          allowed-users = [ "@wheel" ];
          trusted-users = [ "@wheel" ];
          accept-flake-config = true;
          extra-experimental-features = [
            "nix-command"
            "flakes"
          ];
          inherit ((import ../../flake.nix).nixConfig)
            extra-substituters
            extra-trusted-public-keys
            ;
        };
        registry = {
          self.flake = self;
          nixpkgs.flake = inputs.nixpkgs;
        };
      };
    };
}
