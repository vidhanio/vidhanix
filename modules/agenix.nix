{ inputs, ... }:
{
  flake.modules.nixos.default = args: {
    imports = [ inputs.agenix.nixosModules.default ];

    # agenix runs via an activation script during stage 2,
    # which is before impermanence runs via systemd.
    age.identityPaths = [
      "${args.config.persist.path}/etc/ssh/ssh_host_ed25519_key"
    ];
  };
}
