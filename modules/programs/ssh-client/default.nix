{ config, lib, ... }:
let
  inherit (config) configurations;
in
{
  flake.aspects.ssh-client = {
    nixos = {
      programs.ssh.knownHosts = {
        "github.com".publicKey =
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
      }
      // lib.mapAttrs (
        hostname:
        { publicKey, ... }:
        {
          inherit publicKey;
          extraHostNames = [ "${hostname}.local" ];
        }
      ) configurations;
    };

    homeManager = {
      persist.files = [ ".ssh/id_ed25519" ];
    };
  };
}
