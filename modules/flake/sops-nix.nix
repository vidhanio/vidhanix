{ inputs, ... }:
{
  flake-file.inputs.sops-nix.url = "github:Mic92/sops-nix";

  perSystem.treefmt.settings.excludes = [ "secrets/secrets.yaml" ];

  flake.modules = {
    nixos.default =
      { config, ... }:
      {
        imports = [ inputs.sops-nix.nixosModules.default ];

        sops.defaultSopsFile = ../../secrets/secrets.yaml;

        # sops-nix runs via an activation script during stage 2, which is
        # before impermanence runs via systemd -- same reasoning as agenix's
        # age.identityPaths before it.
        sops.age.sshKeyPaths = [
          "${config.persist.persistentStoragePath}/etc/ssh/ssh_host_ed25519_key"
        ];
      };

    homeManager.default =
      { osConfig, ... }:
      {
        imports = [ inputs.sops-nix.homeManagerModules.default ];

        sops.defaultSopsFile = ../../secrets/secrets.yaml;

        sops.age.sshKeyPaths = [
          "${osConfig.persist.persistentStoragePath}/etc/ssh/ssh_host_ed25519_key"
        ];
      };
  };
}
