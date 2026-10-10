{ inputs, ... }:
{
  profiles.pc = {
    module = {
      services.flatpak.enable = true;
      persist.directories = [ "/var/lib/flatpak" ];
    };

    homeModule = {
      imports = [ inputs.nix-flatpak.homeManagerModules.nix-flatpak ];
      services.flatpak = {
        enable = true;
        update.onActivation = true;
      };
      persist.directories = [
        ".local/share/flatpak"
        ".var/app"
      ];
    };
  };
}
