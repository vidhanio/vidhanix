{ config, ... }:
{
  programs.ssh.knownHosts = {
    "github.com".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
  };

  services.openssh.enable = true;

  persist.files = [ "/etc/ssh/ssh_host_ed25519_key" ];

  # agenix runs via an activation script during stage 2,
  # which is before impermanence runs via systemd.
  age.identityPaths = [
    "${config.persist.path}/etc/ssh/ssh_host_ed25519_key"
  ];
}
