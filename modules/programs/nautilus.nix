{
  flake.modules.homeManager.default =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.nautilus ];

      dconf.settings = {
        "org/gnome/nautilus/preferences".show-delete-permanently = true;
        "org/gtk/gtk4/settings/file-chooser".show-hidden = true;
      };
    };
}
