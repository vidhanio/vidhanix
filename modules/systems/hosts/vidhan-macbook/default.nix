{ den, ... }:
{
  den.hosts.aarch64-linux.vidhan-macbook = {
    primaryUser = "vidhanio";
    sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINrlsMqmLKW+8+MyHndMWNZXk86Oo0Ik8wPs3v1Nx7ZR root@vidhan-macbook";

    users.vidhanio.sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKpEHUbyfwBLGJqsrZLO8xDpldmg655DPYLGNOJUJfHM vidhanio@vidhan-macbook";
  };

  den.aspects.vidhan-macbook = {
    includes = [ den.aspects.macbook ];

    nixos = {
      hardware.monitors.main = {
        name = "eDP-1";
        position = {
          x = 0;
          y = 0;
        };
        scale = 1.6;
      };
      system.stateVersion = "26.05";
    };
  };
}
