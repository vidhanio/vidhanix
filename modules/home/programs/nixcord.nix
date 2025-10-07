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
      discord.enable = lib.mkDefault false;
      vesktop = {
        package = pkgs.vesktop.overrideAttrs (
          finalAttrs: previousAttrs: {
            version = "latest";

            src = inputs.vesktop;

            pnpmDeps = pkgs.pnpm_10.fetchDeps {
              inherit (finalAttrs)
                pname
                version
                src
                patches
                ;
              fetcherVersion = 2;
              hash = "sha256-Vn+Imarp1OTPfe/PoMgFHU5eWnye5Oa+qoGZaTxOUmU=";
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
