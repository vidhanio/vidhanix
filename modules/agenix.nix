{ inputs, ... }:
{
  flake-file.inputs.agenix.url = "github:ryantm/agenix";

  flake.modules = {
    nixos.default =
      { config, ... }:
      {
        imports = [ inputs.agenix.nixosModules.default ];

        # agenix runs via an activation script during stage 2,
        # which is before impermanence runs via systemd.
        age.identityPaths = [
          "${config.persist.persistentStoragePath}/etc/ssh/ssh_host_ed25519_key"
        ];
      };
    homeManager.default = {
      imports = [ inputs.agenix.homeManagerModules.default ];
    };
  };
}
