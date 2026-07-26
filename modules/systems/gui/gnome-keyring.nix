{
  den.default = {
    nixos = {
      services.gnome.gnome-keyring.enable = true;
      programs.seahorse.enable = true;

      security.pam.services = {
        greetd.enableGnomeKeyring = true;
        login.enableGnomeKeyring = true;
      };
    };

    homeManager = {
      persist.directories = [ ".local/share/keyrings" ];
    };
  };
}
