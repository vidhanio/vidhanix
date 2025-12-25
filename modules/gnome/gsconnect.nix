{ pkgs, ... }:
{
  flake.modules = {
    nixos.default = {
      programs.kdeconnect = {
        enable = true;
        package = pkgs.gnomeExtensions.gsconnect;
      };
    };
    homeManager.default = {
      programs.gnome-shell.extensions = with pkgs.gnomeExtensions; [
        { package = gsconnect; }
      ];
    };
  };
}
