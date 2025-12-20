{
  flake.modules.nixos.default = {
    programs.dconf.profiles.user.databases = [
      {
        settings =
          let
            keybindingName = "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/1password-quick-access";
          in
          {
            "org/gnome/settings-daemon/plugins/media-keys" = {
              custom-keybindings = [ "/${keybindingName}/" ];
            };
            ${keybindingName} = {
              name = "1Password Quick Access";
              command = "1password --quick-access";
              binding = "<Control>backslash";
            };
          };
      }
    ];
  };
}
