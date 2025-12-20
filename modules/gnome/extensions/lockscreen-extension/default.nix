{
  flake.modules.homeManager.default =
    { pkgs, ... }:
    {
      programs.gnome-shell.extensions = with pkgs.gnomeExtensions; [
        { package = lockscreen-extension; }
      ];
    };
}
