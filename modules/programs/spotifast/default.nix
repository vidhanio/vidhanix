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
          settings = {
            device_name = osConfig.networking.hostName;
            web_client_id = "429622441b094d4f92367a58c033d77a";
          };
        };
        binds."SUPER + s".app = "spotifast";

        xdg.autostart.entries = [
          "${config.programs.spotifast.package}/share/applications/spotifast.desktop"
        ];

        wayland.windowManager.hyprland.autostartWorkspaces.spotifast = 2;

        persist.directories = [
          ".local/state/spotifast"
        ];
      };
  };
}
