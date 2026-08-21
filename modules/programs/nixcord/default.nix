{ inputs, lib, ... }:
{
  flake-file.inputs.nixcord.url = "github:4evy/nixcord";

  flake.aspects.nixcord = {
    homeManager =
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
            transparent = lib.mkIf (config.stylix.opacity.applications < 1.0) true;
            plugins = {
              # keep-sorted start
              clearUrls.enable = true;
              collapsibleUi.enable = true;
              equibopStreamFixes.enable = true;
              fakeNitro.enable = true;
              spotifyCrack.enable = true;
              volumeBooster.enable = true;
              youtubeAdblock.enable = true;
              # keep-sorted end
            };
          };
        };

        stylix.targets.nixcord.extraCss = lib.mkIf (config.stylix.opacity.applications < 1.0) ''
          :root {
            --window-opacity: ${toString config.stylix.opacity.applications};
            --discord-window: calc(var(--window-opacity) * 0.32);
            --discord-rail: 36%;
            --discord-sidebar: 24%;
            --discord-content: 4%;
            --discord-members: 16%;
            --discord-raised: 30%;
            --discord-border: 12%;
          }

          :is(.theme-light, .theme-dark, .theme-darker, .theme-midnight, .visual-refresh) {
            --background-primary: rgb(from var(--base00) r g b / var(--discord-content)) !important;
            --background-secondary: rgb(from var(--base00) r g b / var(--discord-sidebar)) !important;
            --background-secondary-alt: rgb(from var(--base00) r g b / var(--discord-raised)) !important;
            --background-tertiary: rgb(from var(--base00) r g b / var(--discord-rail)) !important;
            --background-base-low: rgb(from var(--base00) r g b / var(--discord-content)) !important;
            --background-base-lower: rgb(from var(--base00) r g b / var(--discord-sidebar)) !important;
            --background-base-lowest: rgb(from var(--base00) r g b / var(--discord-rail)) !important;
            --background-base-tertiary: rgb(from var(--base00) r g b / var(--discord-rail)) !important;
            --bg-base-primary: rgb(from var(--base00) r g b / var(--discord-content)) !important;
            --bg-base-secondary: rgb(from var(--base00) r g b / var(--discord-sidebar)) !important;
            --bg-base-tertiary: rgb(from var(--base00) r g b / var(--discord-rail)) !important;
            --bg-overlay-app-frame: rgb(from var(--base00) r g b / var(--discord-window)) !important;
            --bg-overlay-chat: rgb(from var(--base00) r g b / var(--discord-content)) !important;
            --chat-background-default: rgb(from var(--base00) r g b / var(--discord-content)) !important;
            --home-background: rgb(from var(--base00) r g b / var(--discord-content)) !important;

            --background-message-hover: rgb(from var(--base05) r g b / 6%) !important;
            --background-modifier-hover: rgb(from var(--base05) r g b / 8%) !important;
            --background-modifier-active: rgb(from var(--base05) r g b / 12%) !important;
            --background-modifier-selected: rgb(from var(--base05) r g b / 16%) !important;
            --background-modifier-accent: rgb(from var(--base05) r g b / var(--discord-border)) !important;
            --background-mentioned: rgb(from var(--base0A) r g b / 12%) !important;
            --background-mentioned-hover: rgb(from var(--base0A) r g b / 18%) !important;
            --background-message-highlight: rgb(from var(--base0A) r g b / 12%) !important;

            --background-code: rgb(from var(--base00) r g b / 44%) !important;
            --channeltextarea-background: rgb(from var(--base00) r g b / var(--discord-raised)) !important;
            --input-background: rgb(from var(--base00) r g b / var(--discord-raised)) !important;
            --modal-background: rgb(from var(--base00) r g b / 88%) !important;
            --modal-footer-background: rgb(from var(--base00) r g b / 94%) !important;
            --background-floating: rgb(from var(--base00) r g b / 92%) !important;
          }

          html,
          body,
          #app-mount,
          [class*="app_"] {
            background: transparent !important;
          }

          html body {
            background: rgb(from var(--base00) r g b / var(--discord-window)) !important;
          }

          html body [class*="bg__"][class*="bg__"] {
            background: transparent !important;
          }

          html body [class*="guilds_"][class*="guilds_"] {
            background-color: rgb(from var(--base00) r g b / var(--discord-rail)) !important;
            border-right: 1px solid rgb(from var(--base05) r g b / var(--discord-border));
          }

          html body :is(
            [class*="sidebarList_"][class*="sidebarList_"],
            [class*="sidebar_"][class*="sidebar_"] > [class*="container_"]
          ) {
            background-color: rgb(from var(--base00) r g b / var(--discord-sidebar)) !important;
          }

          html body :is(
            [class*="chatContent_"][class*="chatContent_"],
            [class*="page_"][class*="page_"]
          ) {
            background-color: rgb(from var(--base00) r g b / var(--discord-content)) !important;
          }

          html body :is(
            [class*="membersWrap_"][class*="membersWrap_"],
            [class*="members_"][class*="members_"]
          ) {
            background-color: rgb(from var(--base00) r g b / var(--discord-members)) !important;
          }

          html body :is(
            [class*="panels_"][class*="panels_"],
            [class*="searchBar_"][class*="searchBar_"],
            [class*="channelTextArea_"][class*="channelTextArea_"]
          ) {
            background-color: rgb(from var(--base00) r g b / var(--discord-raised)) !important;
            border-color: rgb(from var(--base05) r g b / var(--discord-border)) !important;
          }

          html body [class*="modalContentInner_"][class*="theme-"] {
            background-color: rgb(from var(--base00) r g b / 92%) !important;
          }

          html body [class*="modalContentInner_"] > [class*="container_"] > [class*="sidebar_"] {
            background-color: rgb(from var(--base00) r g b / var(--discord-sidebar)) !important;
            border-right: 1px solid rgb(from var(--base05) r g b / var(--discord-border));
          }

          :is(.theme-light, .theme-dark, .theme-darker, .theme-midnight, .visual-refresh) [class*="chatGradient_"] {
            background: none !important;
          }
        '';

        xdg.autostart.entries = [
          "${config.programs.nixcord.equibop.package}/share/applications/equibop.desktop"
        ];

        hyprland.autostartWorkspaces.equibop = 2;

        persist.directories = [ ".config/equibop/sessionData/Local Storage" ];
      };
  };
}
