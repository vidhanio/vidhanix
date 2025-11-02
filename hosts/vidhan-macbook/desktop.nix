{
  programs.dconf.profiles.user.databases = [
    {
      settings = {
        "org/gnome/desktop/wm/keybindings" = {
          switch-windows = [ "<Ctrl>Tab" ];
          switch-windows-backward = [ "<Shift><Ctrl>Tab" ];
        };
        "org/gnome/mutter" = {
          experimental-features = [ "scale-monitor-framebuffer" ];
        };
        "org/gnome/settings-daemon/plugins/media-keys" = {
          custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/kbbrightnessdown/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/kbbrightnessup/"
          ];
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/kbbrightnessdown" = {
          name = "Keyboard brightness down";
          command = "gdbus call --session --dest org.gnome.SettingsDaemon.Power --object-path /org/gnome/SettingsDaemon/Power --method org.gnome.SettingsDaemon.Power.Keyboard.StepDown";
          binding = "<Shift>MonBrightnessDown";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/kbbrightnessup" = {
          name = "Keyboard brightness up";
          command = "gdbus call --session --dest org.gnome.SettingsDaemon.Power --object-path /org/gnome/SettingsDaemon/Power --method org.gnome.SettingsDaemon.Power.Keyboard.StepUp";
          binding = "<Shift>MonBrightnessUp";
        };
      };
    }
  ];
}
