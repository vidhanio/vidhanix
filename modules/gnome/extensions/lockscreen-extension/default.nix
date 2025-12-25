{
  pkgs,
  ...
}:
{
  flake.modules.homeManager.default = {
    programs.gnome-shell.extensions = with pkgs.gnomeExtensions; [
      { package = lockscreen-extension; }
    ];
  };
}
