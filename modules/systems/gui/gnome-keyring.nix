{
  flake.modules = {
    nixos.default = {
      services.gnome.gnome-keyring.enable = true;
      programs.seahorse.enable = true;

      security.pam.services = {
        greetd.enableGnomeKeyring = true;
        login.enableGnomeKeyring = true;
      };
    };

    homeManager.default = {
      persist.directories = [ ".local/share/keyrings" ];
    };
  };
}
