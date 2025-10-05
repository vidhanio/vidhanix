{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.programs.nixcord;
in
lib.mkMerge [
  {
    programs.nixcord = {
      discord.enable = lib.mkDefault false;
      vesktop = {
        package = pkgs.vesktop.overrideAttrs (
          finalAttrs: previousAttrs: {
            version = "latest";

            src = pkgs.fetchFromGitHub {
              owner = "Vencord";
              repo = "Vesktop";
              rev = "refs/heads/main";
              hash = "sha256-D9ZoSIg0+W77FWTDMP0K0ylUTDnAPgX56U6+7IWpfJo=";
            };

            pnpmDeps = pkgs.pnpm_10.fetchDeps {
              inherit (finalAttrs)
                pname
                version
                src
                patches
                ;
              fetcherVersion = 2;
              hash = "sha256-MKvdpCUsUp0d/SFGyXp93Hj7D1ShE/nsrOa6yxT6EzY=";
            };
          }
        );
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

    impermanence.directories = [ ".config/vesktop/sessionData" ];
  })
]
