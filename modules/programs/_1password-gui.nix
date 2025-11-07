{
  config,
  lib,
  ...
}:
let
  cfg = config.programs._1password-gui;
in
lib.mkIf cfg.enable {
  environment.etc = {
    "1password/custom_allowed_browsers" = {
      text = ''
        firefox-devedition
      '';
      mode = "0755";
    };
  };

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

  home-manager.sharedModules = [
    {
      persist.directories = [ ".config/1Password" ];
    }
  ];
}
