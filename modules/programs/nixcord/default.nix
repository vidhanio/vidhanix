{ inputs, ... }:
{
  flake-file.inputs.nixcord.url = "github:4evy/nixcord";

  flake.modules.homeManager.default =
    { config, pkgs, ... }:
    {
      imports = [ inputs.nixcord.homeModules.default ];

      programs.nixcord.vesktop.package = pkgs.vesktop.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [ ./vesktop-webrtc-policy.patch ];
      });

      programs.nixcord = {
        enable = true;
        discord.enable = false;
        vesktop = {
          enable = true;
          settings = {
            discordBranch = "canary";
            minimizeToTray = true;
            arRPC = true;
            hardwareAcceleration = true;
            hardwareVideoAcceleration = true;
            # customTitleBar = false;
          };
          state = {
            firstLaunch = false;
          };
        };
        quickCss = ''
          @import url(https://codeberg.org/ridge/Discord-Adblock/raw/branch/main/discord-adblock.css);
        '';
        config = {
          useQuickCss = true;
          disableMinSize = true;
          transparent = true;
          plugins = {
            # keep-sorted start
            clearUrls.enable = true;
            fakeNitro.enable = true;
            spotifyCrack.enable = true;
            volumeBooster.enable = true;
            youtubeAdblock.enable = true;
            # keep-sorted end
          };
        };
      };

      stylix.targets.nixcord.colors.override = with config.lib.stylix.colors; {
        base00 = "${base00}80";
        base01 = "${base01}80";
        base02 = "${base02}80";
      };

      xdg.autostart.entries = [
        "${config.programs.nixcord.vesktop.package}/share/applications/vesktop.desktop"
      ];

      hyprland.autostartWorkspaces.vesktop = 2;

      persist.directories = [ ".config/vesktop/sessionData/Local Storage" ];
    };
}
