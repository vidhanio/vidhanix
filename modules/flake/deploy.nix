{
  config,
  inputs,
  lib,
  withSystem,
  ...
}:
{
  flake.deploy = {
    user = "root";
    sudo = "run0 --user";
    remoteBuild = true;
    nodes = lib.mapAttrs (
      hostname: nixos:
      withSystem nixos.pkgs.stdenv.hostPlatform.system (
        { pkgs, ... }:
        let
          deployPkgs = pkgs.appendOverlays [
            inputs.deploy-rs.overlays.default
            (_: prev: {
              deploy-rs = {
                inherit (pkgs) deploy-rs;
                inherit (prev.deploy-rs) lib;
              };
            })
          ];
        in
        {
          inherit hostname;
          sshUser = nixos.config.users.primaryUser;
          profiles.system.path = deployPkgs.deploy-rs.lib.activate.nixos nixos;
        }
      )
    ) config.flake.nixosConfigurations;
  };
}
