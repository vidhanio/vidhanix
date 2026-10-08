{ inputs, ... }:
{
  perSystem.treefmt.settings.excludes = [ "secrets.yaml" ];

  profiles.base =
    let
      mkSopsConfig = key: {
        defaultSopsFile = ../../secrets.yaml;
        # TODO: https://github.com/Mic92/sops-nix/pull/779
        environment.SOPS_AGE_SSH_PRIVATE_KEY_FILE = key;
        age.sshKeyPaths = [ key ];
      };
    in
    {
      module =
        { config, ... }:
        {
          imports = [ inputs.sops-nix.nixosModules.default ];
          sops = mkSopsConfig "${config.persist.persistentStoragePath}/etc/ssh/ssh_host_ed25519_key";
        };
      homeModule =
        { config, ... }:
        {
          imports = [ inputs.sops-nix.homeManagerModules.default ];
          sops = mkSopsConfig "${config.home.homeDirectory}/.ssh/id_ed25519";
        };
    };
}
