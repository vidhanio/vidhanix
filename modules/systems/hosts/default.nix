{
  lib,
  den,
  config,
  ...
}:
let
  allHosts = builtins.concatMap builtins.attrValues (builtins.attrValues den.hosts);
  inherit (config) people;

  userKeysAcrossHosts =
    username:
    lib.concatMap (
      host: lib.optional (host.users ? ${username}) host.users.${username}.sshPublicKey
    ) allHosts;

  rootPublicKeys = map (host: host.sshPublicKey) allHosts;
in
{
  den.schema.host = {
    options.sshPublicKey = lib.mkOption {
      type = lib.types.str;
      description = "This host's own SSH public key, used for programs.ssh.knownHosts and as an authorized key for every user on every host.";
    };

    options.primaryUser = lib.mkOption {
      type = lib.types.str;
      default = "vidhanio";
      description = "The primary/main interactive user of this host.";
    };

    includes = [
      ({ host, ... }: {
        nixos =
          { config, ... }:
          {
            # neededForUsers decrypts to /run/secrets-for-users before NixOS
            # creates users, since hashedPasswordFile can't reference a
            # secret decrypted by the normal (later) sops-nix activation step.
            sops.secrets = lib.mapAttrs' (
              username: _: lib.nameValuePair "passwords/${username}" { neededForUsers = true; }
            ) host.users;

            users.users = lib.mapAttrs (username: _: {
              description = people.${username}.fullName;
              hashedPasswordFile = config.sops.secrets."passwords/${username}".path;
              useDefaultShell = true;
              openssh.authorizedKeys.keys =
                people.${username}.extraPublicKeys ++ userKeysAcrossHosts username ++ rootPublicKeys;
            }) host.users;
          };
      })
    ];
  };

  den.schema.user.options.sshPublicKey = lib.mkOption {
    type = lib.types.str;
    description = "This user's SSH public key specific to the host they're declared on.";
  };

  den.default.includes = [ den.batteries.hostname ];

  den.default.nixos = {
    programs.ssh.knownHosts = lib.listToAttrs (
      map (
        host:
        lib.nameValuePair host.hostName {
          publicKey = host.sshPublicKey;
          extraHostNames = [ "${host.hostName}.local" ];
        }
      ) allHosts
    );
  };
}
