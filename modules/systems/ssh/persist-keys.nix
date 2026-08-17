{
  flake.aspects.ssh-server = {
    nixos = {
      persist.files = [ "/etc/ssh/ssh_host_ed25519_key" ];
    };
    homeManager = {
      persist.files = [ ".ssh/id_ed25519" ];
    };
  };
}
