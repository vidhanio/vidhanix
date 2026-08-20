{ config, lib, ... }:
let
  inherit (config) hosts;
  inherit (config) users;
  rootPublicKeys = lib.mapAttrsToList (_: host: host.publicKey) hosts;
in
{
  flake.aspects.ssh-server = {
    nixos =
      { config, ... }:
      let
        activeUsers = lib.filterAttrs (
          username: _: hosts.${config.networking.hostName}.users.${username}.enable
        ) users;
      in
      {
        services.openssh = {
          enable = true;
          settings = {
            PasswordAuthentication = false;
            KbdInteractiveAuthentication = false;
            PermitRootLogin = "no";
          };
        };

        users.users = lib.mapAttrs (_: user: {
          openssh.authorizedKeys.keys = user.publicKeys ++ rootPublicKeys;
        }) activeUsers;

        services.fail2ban.enable = true;
        persist.files = [
          {
            file = "/etc/ssh/ssh_host_ed25519_key";
            mode = "0600";
            configureParent = true;
            parent.mode = "0755";
          }
        ];
      };
  };
}
