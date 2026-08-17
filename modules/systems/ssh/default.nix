{
  flake.aspects.ssh-server.nixos = {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    services.fail2ban.enable = true;
  };
}
