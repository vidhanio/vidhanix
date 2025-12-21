{
  flake.modules.nixos.default = {
    persist.files = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };
}
