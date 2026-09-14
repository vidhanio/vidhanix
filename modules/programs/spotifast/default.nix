_: {

  flake.aspects.spotifast = {
    homeManager =
      {
        config,
        osConfig,
        ...
      }:
      {
        programs.spotifast = {
          enable = true;
          settings.device_name = osConfig.networking.hostName;
        };
        binds."SUPER + s".app = "spotifast";

        xdg.autostart.entries = [
          "${config.programs.spotifast.package}/share/applications/spotifast.desktop"
        ];

        wayland.windowManager.hyprland.autostartWorkspaces.spotifast = 2;

        # upstream keeps the pre-rename state directory.
        persist.directories = [
          ".local/state/fastpotify"
        ];
      };
  };
}
