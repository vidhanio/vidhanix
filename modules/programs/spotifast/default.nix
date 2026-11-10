{
  profiles.pc = {
    homeModule =
      {
        config,
        lib,
        osConfig,
        pkgs,
        ...
      }:
      let
        soloistBuilds =
          pkgs.runCommand "spotifast-soloist-builds"
            {
              nativeBuildInputs = [
                pkgs.coreutils
                pkgs.jq
              ];
            }
            ''
              read -r _ version _ built _ < <(${lib.getExe pkgs.soloist} --version)
              digest=$(sha256sum ${lib.getExe pkgs.soloist} | cut -d ' ' -f 1)
              mkdir -p "$out/$digest"
              ln -s ${lib.getExe pkgs.soloist} "$out/$digest/soloist"
              jq -n \
                --arg version "$version" \
                --argjson built "$built" \
                --arg digest "$digest" \
                '{version: $version, built: $built, checked: 0, digest: $digest}' \
                > "$out/current.json"
            '';
      in
      {
        programs.spotifast = {
          enable = true;
          settings = {
            device_name = osConfig.networking.hostName;
            web_client_id = "429622441b094d4f92367a58c033d77a";
            accent_from_art = false;
            player_bar_vis_click = false;
            soloist_enabled = true;
          };
        };

        home.file."${config.xdg.stateHome}/spotifast/soloist/builds" = {
          source = soloistBuilds;
          recursive = true;
        };
        desktop.binds."SUPER + s".app = {
          cmd = "spotifast";
          focusAppId = "spotifast";
        };
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
