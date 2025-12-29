{
  programs.dconf.profiles.user.databases = [
    {
      settings =
        let
          dir = {
            up = {
              lower = "up";
              title = "Up";
            };
            down = {
              lower = "down";
              title = "Down";
            };
          };

          keybindingName =
            d:
            "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/keyboard-brightness-${dir.${d}.lower}";

          keybinding = d: {
            name = "Keyboard brightness ${dir.${d}.lower}";
            command = "gdbus call --session --dest org.gnome.SettingsDaemon.Power --object-path /org/gnome/SettingsDaemon/Power --method org.gnome.SettingsDaemon.Power.Keyboard.Step${dir.${d}.title}";
            binding = "<Shift>MonBrightness${dir.${d}.title}";
          };
        in
        {
          "org/gnome/desktop/wm/keybindings" = {
            switch-windows = [ "<Ctrl>Tab" ];
            switch-windows-backward = [ "<Shift><Ctrl>Tab" ];
          };
          "org/gnome/mutter" = {
            experimental-features = [
              "scale-monitor-framebuffer"
              "xwayland-native-scaling"
            ];
          };
          "org/gnome/settings-daemon/plugins/media-keys" = {
            custom-keybindings = map (d: "/${keybindingName d}/") [
              "down"
              "up"
            ];
          };
          ${keybindingName "down"} = keybinding "down";
          ${keybindingName "up"} = keybinding "up";
        };
    }
  ];
}
