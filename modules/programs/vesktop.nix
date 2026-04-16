{ inputs, ... }:
{
  flake-file.inputs.nixcord.url = "github:FlameFlag/nixcord";

  flake.modules.homeManager.default =
    { config, ... }:
    {
      imports = [ inputs.nixcord.homeModules.default ];

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
            customTitleBar = false;
            disableMinSize = true;
          };
          state = {
            firstLaunch = false;
            maximized = true;
          };
        };
        quickCss = ''
          @import url(https://codeberg.org/ridge/Discord-Adblock/raw/branch/main/discord-adblock.css);
        '';
        config = {
          useQuickCss = true;
          plugins = {
            # keep-sorted start
            ClearURLs.enable = true;
            fakeNitro.enable = true;
            spotifyCrack.enable = true;
            volumeBooster.enable = true;
            youtubeAdblock.enable = true;
            # keep-sorted end
          };
        };
      };

      xdg.autostart.entries = [
        "${config.programs.nixcord.vesktop.package}/share/applications/vesktop.desktop"
      ];

      hyprland.autostartWorkspaces.vesktop = 2;

      persist.directories = [ ".config/vesktop/sessionData/Local Storage" ];
    };
}
