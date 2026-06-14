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
        equibop = {
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
            clearUrls.enable = true;
            fakeNitro.enable = true;
            spotifyCrack.enable = true;
            volumeBooster.enable = true;
            youtubeAdblock.enable = true;
            # keep-sorted end
          };
        };
      };

      xdg.autostart.entries = [
        "${config.programs.nixcord.equibop.package}/share/applications/Equibop.desktop"
      ];

      hyprland.autostartWorkspaces.equibop = 2;

      persist.directories = [ ".config/equibop/sessionData/Local Storage" ];
    };
}
