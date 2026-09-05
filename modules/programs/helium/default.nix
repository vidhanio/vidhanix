{
  flake-file.inputs.helium.url = "github:schembriaiden/helium-browser-nix-flake";

  flake.aspects.helium = {
    homeManager =
      {
        config,
        inputs',
        lib,
        pkgs,
        ...
      }:
      let
        colors = config.lib.stylix.colors;
        lua = pkgs.formats.lua { };
        rgb =
          name:
          map (channel: lib.toInt colors."${name}-rgb-${channel}") [
            "r"
            "g"
            "b"
          ];
        theme = pkgs.writeTextDir "manifest.json" (
          builtins.toJSON {
            manifest_version = 3;
            name = "Stylix";
            version = "1.0.0";

            theme = {
              colors = {
                frame = rgb "base00";
                frame_inactive = rgb "base01";
                toolbar = rgb "base02";
                background_tab = rgb "base00";
                background_tab_inactive = rgb "base01";

                bookmark_text = rgb "base05";
                button_background = rgb "base00";
                tab_background_text = rgb "base04";
                tab_background_text_inactive = rgb "base03";
                tab_text = rgb "base05";
                toolbar_button_icon = rgb "base05";

                frame_incognito = rgb "base00";
                frame_incognito_inactive = rgb "base02";
                tab_background_text_incognito = rgb "base05";
                tab_background_text_incognito_inactive = rgb "base04";

                omnibox_text = rgb "base0A";
                omnibox_background = rgb "base00";

                ntp_background = rgb "base00";
                ntp_header = rgb "base01";
                ntp_link = rgb "base04";
                ntp_text = rgb "base04";
              };

              tints = {
                buttons = [
                  (-1)
                  (-1)
                  (-1)
                ];
                frame = [
                  (-1)
                  (-1)
                  (-1)
                ];
                frame_inactive = [
                  (-1)
                  (-1)
                  (-1)
                ];
                frame_incognito = [
                  (-1)
                  (-1)
                  (-1)
                ];
                frame_incognito_inactive = [
                  (-1)
                  (-1)
                  (-1)
                ];
              };

              properties = {
                ntp_background_alignment = "bottom";
                ntp_logo_alternate = 1;
              };
            };
          }
        );
        unwrapped = inputs'.helium.packages.default;
        pkg = pkgs.symlinkJoin {
          inherit (unwrapped) pname version meta;
          paths = [ unwrapped ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/helium \
              --add-flags ${lib.escapeShellArg "--load-extension=${theme}"}
          '';
        };
      in
      {
        home.packages = [ pkg ];

        xdg.autostart.entries = [ "${pkg}/share/applications/helium.desktop" ];

        wayland.windowManager.hyprland = {
          autostartWorkspaces.helium = 1;

          binds = {
            "SUPER + B" = lua.lib.mkRaw ''
              function()
                local window = hl.get_window("class:helium")
                if window then
                  hl.dispatch(hl.dsp.focus({ window = window }))
                else
                  hl.exec_cmd("uwsm app -- helium")
                end
              end
            '';
            "SUPER + SHIFT + B".exec_cmd = "uwsm app -- helium --new-window";
          };
        };

        persist.directories = [ ".config/net.imput.helium" ];
      };
  };
}
