{
  flake.modules = {
    nixos.default = {
      persist.files = [ "/etc/ssh/ssh_host_ed25519_key" ];
    };
    homeManager.default = {
      persist.files = [ ".ssh/id_ed25519" ];
    };
  };
}
