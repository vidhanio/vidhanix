{
  lib,
  config,
  ...
}:
let
  cfg = config.programs.nixcord;
in
lib.mkMerge [
  {
    programs.nixcord = {
      discord.settings = {
        enableHardwareAcceleration = true;
        isMaximized = true;
      };
    };
  }
  (lib.mkIf cfg.enable {
    xdg.autostart.entries = map lib.getDesktop [ cfg.finalPackage.discord ];

    # impermanence.directories = map [ ".config/discord/sessionData" ];
  })
]
