{
  flake.aspects.ssh-server = {
    nixos = {
      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          PermitRootLogin = "no";
        };
      };

      services.fail2ban.enable = true;
      persist.files = [ "/etc/ssh/ssh_host_ed25519_key" ];
    };

    homeManager.persist.files = [ ".ssh/id_ed25519" ];
  };
}
