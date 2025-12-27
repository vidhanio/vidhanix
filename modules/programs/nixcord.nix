# {
#   lib,
#   config,
#   pkgs,
#   ...
# }:
# let
#   cfg = config.programs.vesktop;
#   json = pkgs.formats.json { };
# in
# {
#   options.programs.vesktop = {
#     state = lib.mkOption {
#       inherit (json) type;
#       default = { };
#       description = ''
#         Vesktop state written to
#         {file}`$XDG_CONFIG_HOME/vesktop/state.json`. See
#         <https://github.com/Vencord/Vesktop/blob/main/src/shared/settings.d.ts>
#         for available options.
#       '';
#     };

#     quickCss = lib.mkOption {
#       type = lib.types.lines;
#       default = "";
#       description = ''
#         Custom CSS to inject into Vesktop.
#       '';
#     };
#   };

#   config = lib.mkMerge [
#     {
#       programs.vesktop = {
#         settings = {
#           discordBranch = "canary";
#           minimizeToTray = true;
#           arRPC = true;
#           hardwareAcceleration = true;
#           hardwareVideoAcceleration = true;
#           customTitleBar = false;
#           disableMinSize = true;
#           plugins = {
#             SpotifyCrack.enabled = true;
#           };
#         };
#         state = {
#           firstLaunch = false;
#           maximized = true;
#         };
#         quickCss = ''
#           @import url(https://codeberg.org/ridge/Discord-Adblock/raw/branch/main/discord-adblock.css);
#         '';
#       };
#     }
#     (lib.mkIf cfg.enable {
#       persist.directories = [ ".config/vesktop/sessionData/Local Storage" ];

#       xdg.configFile = {
#         "vesktop/state.json" = lib.mkIf (cfg.state != { }) {
#           source = json.generate "vesktop-state" cfg.state;
#         };
#         "vesktop/settings/quickCss.css" = lib.mkIf (cfg.quickCss != "") {
#           text = cfg.quickCss;
#         };
#       };
#     })
#   ];
# }

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
      config = {
        useQuickCss = true;
        quickCss = ''
          @import url(https://codeberg.org/ridge/Discord-Adblock/raw/branch/main/discord-adblock.css);
        '';
        plugins = {
          spotifyCrack.enable = true;
          fakeNitro.enable = true;
          youtubeAdblock.enable = true;
        };
      };
    };
  };
}
