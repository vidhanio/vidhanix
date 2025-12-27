{
  flake.modules = {
    nixos.default =
      { pkgs, ... }:
      {
        programs.kdeconnect = {
          enable = true;
          package = pkgs.gnomeExtensions.gsconnect;
        };
      };
    homeManager.default =
      { pkgs, ... }:
      {
        programs.gnome-shell.extensions = with pkgs.gnomeExtensions; [
          { package = gsconnect; }
        ];
      };
  };
}
