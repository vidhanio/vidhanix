{
  flake.aspects.hermes = {
    homeManager =
      { config, pkgs, ... }:
      let
        theme = "stylix";

        palette = config.lib.stylix.colors.withHashtag;
        sansFont = config.stylix.fonts.sansSerif.name;
        monoFont = config.stylix.fonts.monospace.name;

        yaml = pkgs.formats.yaml { };
      in
      {
        services.hermes-agent = {
          settings = {
            display.skin = theme;
            dashboard.theme = theme;
            terminal.font_family = monoFont;
          };

          hermesHomeFiles = {
            "skins/${theme}.yaml" = "${yaml.generate "hermes-${theme}-skin.yaml" {
              name = theme;
              description = "Stylix base16 palette";

              colors = with palette; {
                background = base00;

                ui_accent = base0D;
                ui_primary = base0D;
                banner_accent = base0D;

                banner_title = base06;
                banner_text = base05;
                ui_text = base05;
                banner_dim = base04;

                ui_border = base03;
                banner_border = base03;

                ui_ok = base0B;
                ui_warn = base0A;
                ui_error = base08;
                ui_label = base0C;

                ui_tool = base0D;
                ui_thinking = base04;

                diff_added = base0B;
                diff_removed = base08;
                diff_added_word = base0B;
                diff_removed_word = base08;

                syntax_string = base0B;
                syntax_number = base09;
                syntax_keyword = base0D;
                syntax_comment = base03;

                prompt = base05;
                input_rule = base03;
                response_border = base03;
                shell_dollar = base0C;
                selection_bg = base02;
                session_label = base0C;
                session_border = base03;

                status_bar_bg = base01;
                status_bar_text = base05;
                status_bar_strong = base06;
                status_bar_dim = base04;
                status_bar_good = base0B;
                status_bar_warn = base0A;
                status_bar_bad = base09;
                status_bar_critical = base08;

                voice_status_bg = base01;
                completion_menu_bg = base01;
                completion_menu_current_bg = base02;
                completion_menu_meta_bg = base01;
                completion_menu_meta_current_bg = base02;
              };
            }}";

            # the desktop and web dashboard skin themselves, independently of the
            # CLI skin above.
            "dashboard-themes/${theme}.yaml" = "${yaml.generate "hermes-${theme}-dashboard.yaml" {
              name = theme;
              label = "Stylix";
              description = "Stylix base16 palette";

              palette = {
                background = palette.base00;
                midground = palette.base0D;
                foreground = palette.base05;
                warmGlow = "${palette.base09}59";
              };

              typography = {
                fontSans = ''"${sansFont}", system-ui, sans-serif'';
                fontMono = ''"${monoFont}", monospace'';
              };

              colorOverrides = {
                card = palette.base01;
                cardForeground = palette.base05;
                popover = palette.base01;
                popoverForeground = palette.base05;
                primary = palette.base0D;
                primaryForeground = palette.base00;
                secondary = palette.base02;
                secondaryForeground = palette.base05;
                muted = palette.base01;
                mutedForeground = palette.base04;
                accent = palette.base0D;
                accentForeground = palette.base00;
                destructive = palette.base08;
                destructiveForeground = palette.base00;
                success = palette.base0B;
                warning = palette.base0A;
                border = palette.base03;
                input = palette.base03;
                ring = palette.base0D;
              };
            }}";
          };
        };
      };
  };
}
