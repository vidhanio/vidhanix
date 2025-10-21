{
  programs.dconf.profiles.user.databases = [
    {
      settings = {
        "org/gnome/desktop/wm/keybindings" = {
          switch-windows = [ "<Ctrl>Tab" ];
          switch-windows-backward = [ "<Shift><Ctrl>Tab" ];
        };
      };
    }
  ];
}
