{ lib, ... }:
{
  flake-file.inputs.fastpotify.url = "github:crmne/fastpotify";

  flake.aspects.fastpotify = {
    homeManager =
      {
        config,
        osConfig,
        pkgs,
        ...
      }:
      {
        programs.fastpotify = {
          enable = true;
          settings.device_name = osConfig.networking.hostName;
        };

        xdg.autostart.entries = lib.mkIf pkgs.stdenv.hostPlatform.isLinux [
          "${config.programs.fastpotify.package}/share/applications/fastpotify.desktop"
        ];

        wayland.windowManager.hyprland.autostartWorkspaces.fastpotify = 2;

        persist.directories = [
          ".config/fastpotify"
          ".local/state/fastpotify"
        ];
      };
  };
}
