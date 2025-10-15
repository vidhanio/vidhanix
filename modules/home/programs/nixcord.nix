{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.programs.nixcord;
in
lib.mkMerge [
  {
    programs.nixcord = {
      discord = {
        enable = lib.mkDefault false;
        branch = "canary";
      };
      vesktop = {
        package = pkgs.vesktop-git;
        settings = {
          discordBranch = "canary";
          minimizeToTray = true;
          arRPC = true;
          hardwareAcceleration = true;
          hardwareVideoAcceleration = true;
          customTitleBar = true;
        };
        state = {
          firstLaunch = false;
          maximized = true;
        };
      };
    };
  }
  (lib.mkIf (cfg.enable && cfg.vesktop.enable) {
    xdg.autostart.entries = map lib.getDesktop [ cfg.finalPackage.vesktop ];

    impermanence.directories = [ ".config/vesktop/sessionData/Local Storage" ];
  })
]
