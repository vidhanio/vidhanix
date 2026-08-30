_: {
  flake-file.inputs.fastpotify.url = "github:crmne/fastpotify";

  flake.aspects.fastpotify = {
    homeManager =
      {
        config,
        osConfig,
        ...
      }:
      {
        programs.fastpotify = {
          enable = true;
          settings.device_name = osConfig.networking.hostName;
        };

        xdg.autostart.entries = [
          "${config.programs.fastpotify.package}/share/applications/fastpotify.desktop"
        ];

        wayland.windowManager.hyprland.autostartWorkspaces.fastpotify = 2;

        persist.directories = [
          ".local/state/fastpotify"
        ];
      };
  };
}
