{
  profiles.pc = {
    module = {
      services.gnome.gnome-keyring.enable = true;
      programs.seahorse.enable = true;

      security.pam.services = {
        greetd.enableGnomeKeyring = true;
        login.enableGnomeKeyring = true;
      };
    };

    homeModule = {
      persist.directories = [ ".local/share/keyrings" ];
    };
  };
}
