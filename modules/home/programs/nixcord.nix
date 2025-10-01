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
    discord.enable = false;
    vesktop.enable = true;
  };

  xdg.autostart.entries = map lib.getDesktop [ cfg.finalPackage.vesktop ];

  impermanence.directories = [ ".config/vesktop/sessionData" ];
}
