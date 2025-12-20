let
  mkAltTabDb = modifier: {
    settings = {
      "org/gnome/desktop/wm/keybindings" = {
        switch-windows = [ "<${modifier}>Tab" ];
        switch-windows-backward = [ "<Shift><${modifier}>Tab" ];
      };
    };
  };
in
{
  flake.modules.nixos = {
    desktop = {
      programs.dconf.profiles.user.databases = [ (mkAltTabDb "Alt") ];
    };
    macbook = {
      programs.dconf.profiles.user.databases = [ (mkAltTabDb "Ctrl") ];
    };
  };
}
