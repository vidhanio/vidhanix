{
  flake.aspects.helium = {
    nixos = {
      stylix.targets.chromium.enable = false;
    };

    homeManager =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        colors = config.lib.stylix.colors;
        rgbList =
          name:
          map (channel: lib.toInt colors."${name}-rgb-${channel}") [
            "r"
            "g"
            "b"
          ];

        manifest = pkgs.writers.writeJSON "manifest.json" {
          manifest_version = 3;
          name = "Stylix";
          version = "1.0.0";

          theme = {
            colors = lib.mapAttrs (_: rgbList) {
              # `frame` currently does nothing: https://github.com/imputnet/helium/issues/1459
              frame = "base00";
              frame_incognito = "base00";

              frame_inactive = "base01";
              frame_incognito_inactive = "base01";

              toolbar = "base00";

              tab_text = "base05";
              bookmark_text = "base05";
              toolbar_text = "base05";

              background_tab = "base01";
              background_tab_inactive = "base01";
              background_tab_incognito = "base01";
              background_tab_incognito_inactive = "base01";

              tab_background_text = "base04";
              tab_background_text_inactive = "base04";
              tab_background_text_incognito = "base04";
              tab_background_text_incognito_inactive = "base04";

              button_background = "base00";

              omnibox_text = "base0D";
              omnibox_background = "base01";

              ntp_background = "base00";
              ntp_header = "base01";
              ntp_link = "base04";
              ntp_text = "base04";
            };

            tints =
              let
                identity = [
                  (-1)
                  (-1)
                  (-1)
                ];
              in
              {
                background_tab = identity;
                buttons = identity;
                frame = identity;
                frame_inactive = identity;
                frame_incognito = identity;
                frame_incognito_inactive = identity;
              };
          };
        };
        theme = pkgs.runCommandLocal "helium-theme" { } ''
          mkdir $out
          ln -s ${manifest} $out/manifest.json
        '';
      in
      {
        programs.helium.commandLineArgs = [
          "--load-extension=${theme}"
        ];
      };
  };
}
