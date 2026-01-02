{ lib, inputs, ... }:
{
  flake.modules.homeManager.default = {
    imports = [ inputs.nixcord.homeModules.default ];

    programs.nixcord = {
      enable = true;
      discord.enable = lib.mkDefault false;
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
          spotifyCrack.enable = true;
          fakeNitro.enable = true;
          youtubeAdblock.enable = true;
        };
      };
    };

    persist.directories = [ ".config/vesktop/sessionData/Local Storage" ];
  };
}
