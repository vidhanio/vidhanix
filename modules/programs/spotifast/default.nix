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
            accent_from_art = false;
          };
        };
        desktop.binds."SUPER + s".app = "spotifast";
        desktop.workspaces.social.apps = [ "spotifast" ];

        xdg.autostart.entries = [
          "${config.programs.spotifast.package}/share/applications/spotifast.desktop"
        ];

        persist.directories = [
          ".local/state/spotifast"
        ];
      };
  };
}
