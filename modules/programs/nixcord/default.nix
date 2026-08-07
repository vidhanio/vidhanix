{ inputs, ... }:
{
  flake-file.inputs.nixcord.url = "github:4evy/nixcord";

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
          plugins = {
            # keep-sorted start
            clearUrls.enable = true;
            collapsibleUi.enable = true;
            equibopStreamFixes.enable = true;
            fakeNitro.enable = true;
            spotifyCrack.enable = true;
            timezones.enable = true;
            volumeBooster.enable = true;
            youtubeAdblock.enable = true;
            # keep-sorted end
          };
        };
      };

      stylix.targets.nixcord.extraCss = ''
        :root {
            --window-opacity: ${toString config.stylix.opacity.applications};
        }

        .theme-light,
        .theme-dark,
        .theme-darker,
        .theme-midnight,
        .visual-refresh {
            --background-primary: transparent !important;
            --background-secondary: transparent !important;
            --background-secondary-alt: transparent !important;
            --background-tertiary: transparent !important;
            --background-base-low: transparent !important;
            --background-base-lower: transparent !important;
            --background-base-lowest: transparent !important;
            --background-base-tertiary: transparent !important;
            --bg-base-primary: transparent !important;
            --bg-base-secondary: transparent !important;
            --bg-base-tertiary: transparent !important;
            --bg-overlay-app-frame: transparent !important;
            --bg-overlay-chat: transparent !important;
            --chat-background-default: transparent !important;
            --home-background: transparent !important;

            /* Hover and selection have to be additive tints now that the
               surfaces they used to sit on are gone. */
            --background-message-hover: rgb(from var(--base05) r g b / 5%) !important;
            --background-modifier-hover: rgb(from var(--base05) r g b / 7%) !important;
            --background-modifier-active: rgb(from var(--base05) r g b / 11%) !important;
            --background-modifier-selected: rgb(from var(--base05) r g b / 15%) !important;
            --background-mentioned: rgb(from var(--base0A) r g b / 10%) !important;
            --background-mentioned-hover: rgb(from var(--base0A) r g b / 16%) !important;
            --background-message-highlight: rgb(from var(--base0A) r g b / 10%) !important;

            /* Blocks that should read as raised without going solid. */
            --background-code: rgb(from var(--base05) r g b / 8%) !important;
            --bg-overlay-3: rgb(from var(--base05) r g b / 8%) !important;
            --channeltextarea-background: rgb(from var(--base05) r g b / 8%) !important;
        }

        /* Stylix's own theme also hardcodes a few element backgrounds straight
           to var(--base00/01) -- the app frame, server rail, channel sidebar,
           chat body and member list -- which the variable overrides above
           cannot reach. Those rules are nested under .visual-refresh, so match
           that specificity; being later in the same file wins the tie. */
        :is(.theme-light, .theme-dark, .theme-darker, .theme-midnight, .visual-refresh) :is(
            [class*="bg__"],
            [class*="guilds_"],
            [class*="sidebar_"],
            [class*="chatContent_"],
            [class*="members_"],
            [class*="member_"],
            [class*="callContainer_"]
        ) {
            background: transparent !important;
        }

        :is(.theme-light, .theme-dark, .theme-darker, .theme-midnight, .visual-refresh) [class*="chatGradient_"] {
            background: none !important;
        }

        /* The single translucent layer. */
        body {
            background-color: rgb(from var(--base00) r g b / var(--window-opacity)) !important;
        }
      '';

      xdg.autostart.entries = [
        "${config.programs.nixcord.vesktop.package}/share/applications/vesktop.desktop"
      ];

      hyprland.autostartWorkspaces.vesktop = 2;

      persist.directories = [ ".config/vesktop/sessionData/Local Storage" ];
    };
}
