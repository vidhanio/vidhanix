{ inputs, lib, ... }:
{
  flake-file.inputs.nixcord.url = "github:4evy/nixcord";

  flake.aspects.nixcord = {
    homeManager =
      { config, ... }:
      let
        alpha =
          color: opacityVar: "rgb(from var(--${color}) r g b / var(--discord-${opacityVar})) !important";
      in
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
            --discord-window: calc(var(--window-opacity) * 0.2);
            --discord-rail: 20%;
            --discord-sidebar: 16%;
            --discord-content: 2%;
            --discord-members: 10%;
            --discord-raised: 22%;
            --discord-border: 10%;
            --discord-message-hover: 6%;
            --discord-hover: 8%;
            --discord-active: 12%;
            --discord-selected: 16%;
            --discord-mentioned: 12%;
            --discord-mentioned-hover: 18%;
            --discord-code: 44%;
            --discord-modal: 88%;
            --discord-modal-footer: 94%;
            --discord-floating: 92%;
          }

          :is(.theme-light, .theme-dark, .theme-darker, .theme-midnight, .visual-refresh) {
            --background-primary: ${alpha "base00" "content"};
            --background-secondary: ${alpha "base00" "sidebar"};
            --background-secondary-alt: ${alpha "base00" "raised"};
            --background-tertiary: ${alpha "base00" "rail"};
            --background-base-low: ${alpha "base00" "content"};
            --background-base-lower: ${alpha "base00" "sidebar"};
            --background-base-lowest: ${alpha "base00" "rail"};
            --background-base-tertiary: ${alpha "base00" "rail"};
            --bg-base-primary: ${alpha "base00" "content"};
            --bg-base-secondary: ${alpha "base00" "sidebar"};
            --bg-base-tertiary: ${alpha "base00" "rail"};
            --bg-overlay-app-frame: ${alpha "base00" "window"};
            --bg-overlay-chat: ${alpha "base00" "content"};
            --chat-background-default: ${alpha "base00" "content"};
            --home-background: ${alpha "base00" "content"};

            --background-message-hover: ${alpha "base05" "message-hover"};
            --background-modifier-hover: ${alpha "base05" "hover"};
            --background-modifier-active: ${alpha "base05" "active"};
            --background-modifier-selected: ${alpha "base05" "selected"};
            --background-modifier-accent: ${alpha "base05" "border"};
            --background-mentioned: ${alpha "base0A" "mentioned"};
            --background-mentioned-hover: ${alpha "base0A" "mentioned-hover"};
            --background-message-highlight: ${alpha "base0A" "mentioned"};

            --background-code: ${alpha "base00" "code"};
            --channeltextarea-background: ${alpha "base00" "raised"};
            --input-background: ${alpha "base00" "raised"};
            --modal-background: ${alpha "base00" "modal"};
            --modal-footer-background: ${alpha "base00" "modal-footer"};
            --background-floating: ${alpha "base00" "floating"};
          }

          html,
          body,
          #app-mount,
          [class*="app_"] {
            background: transparent !important;
          }

          html body {
            background: ${alpha "base00" "window"};
          }

          html body [class*="bg__"][class*="bg__"] {
            background: transparent !important;
          }

          html body :is(
            [class^="bar_"][class*="theme-"],
            [class*="guilds_"][class*="guilds_"]
          ) {
            background-color: ${alpha "base00" "window"};
          }

          html body [class*="guilds_"][class*="guilds_"] {
            border-right: 1px solid rgb(from var(--base05) r g b / var(--discord-border));
          }

          html body :is(
            [class*="sidebarList_"][class*="sidebarList_"],
            [class*="sidebar_"][class*="sidebar_"] > [class*="container_"]
          ) {
            background-color: ${alpha "base00" "sidebar"};
          }

          html body :is(
            [class*="chatContent_"][class*="chatContent_"],
            [class*="page_"][class*="page_"]
          ) {
            background-color: ${alpha "base00" "content"};
          }

          html body [class*="container_"][class*="container_"]:has(
            > [class*="list_"] [class*="headerRow_"]
          ) {
            background-color: ${alpha "base00" "content"};
          }

          html body [class*="container_"][class*="container_"][class*="mainCard_"][class*="mainCard_"]:hover {
            background: ${alpha "base05" "hover"};
          }

          html body :is(
            [class*="membersWrap_"][class*="membersWrap_"],
            [class*="members_"][class*="members_"]
          ) {
            background-color: ${alpha "base00" "members"};
          }

          html body :is(
            [class*="panels_"][class*="panels_"],
            [class*="searchBar_"][class*="searchBar_"],
            [class*="channelTextArea_"][class*="channelTextArea_"]
          ) {
            background-color: ${alpha "base00" "raised"};
            border-color: ${alpha "base05" "border"};
          }

          html body [class*="modalContentInner_"][class*="theme-"] {
            background-color: ${alpha "base00" "floating"};
          }

          html body [class*="modalContentInner_"] > [class*="container_"] > [class*="sidebar_"] {
            background-color: ${alpha "base00" "sidebar"};
            border-right: 1px solid rgb(from var(--base05) r g b / var(--discord-border));
          }

          :is(.theme-light, .theme-dark, .theme-darker, .theme-midnight, .visual-refresh) [class*="chatGradient_"] {
            background: none !important;
          }
        '';

        xdg.autostart.entries = [
          "${config.programs.nixcord.equibop.package}/share/applications/equibop.desktop"
        ];

        wayland.windowManager.hyprland.autostartWorkspaces.equibop = 2;

        persist.directories = [ ".config/equibop/sessionData/Local Storage" ];
      };
  };
}
