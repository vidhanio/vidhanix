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
      discord.enable = false;
      vesktop = {
        enable = true;
        settings = {
          discordBranch = "canary";
          minimizeToTray = true;
          arRPC = true;
          hardwareAcceleration = true;
          hardwareVideoAcceleration = true;
        };
        state = {
          firstLaunch = false;
          maximized = true;
        };
      };
    };
  }
  (lib.mkIf cfg.enable {
    xdg.autostart.entries = map lib.getDesktop [ cfg.finalPackage.vesktop ];

    impermanence.directories = [ ".config/vesktop/sessionData" ];
  })
]
