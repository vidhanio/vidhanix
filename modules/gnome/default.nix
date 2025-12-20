{
  flake.modules.nixos.default =
    { pkgs, ... }:
    {
      services = {
        displayManager.gdm.enable = true;
        desktopManager.gnome.enable = true;
      };

      environment.gnome.excludePackages = with pkgs; [
        gnome-tour
      ];
    };
}
