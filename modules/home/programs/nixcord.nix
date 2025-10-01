{
  lib,
  config,
  ...
}:
let
  cfg = config.programs.nixcord;
in
lib.mkIf cfg.enable {
  programs.nixcord = {
    vesktop.enable = true;
    config.themeLinks = [
      "https://raw.githubusercontent.com/ashtrath/Tokyo-Night/main/themes/tokyo-night.theme.css"
    ];
  };

  xdg.autostart.entries = map lib.getDesktop [ cfg.finalPackage.vesktop ];

  impermanence.directories = [ ".config/vesktop/sessionData" ];

  stylix.targets.nixcord.enable = false;
}
