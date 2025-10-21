{
  programs.dconf.profiles.user.databases = [
    {
      settings = {
        "org/gnome/desktop/wm/keybindings" = {
          switch-windows = [ "<Alt>Tab" ];
          switch-windows-backward = [ "<Shift><Alt>Tab" ];
        };
      };
    }
  ];
}
