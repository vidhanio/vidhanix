{
  flake.modules.homeManager.default =
    { config, ... }:
    {
      programs.hermes = {
        settings.display.skin = "stylix";

        skins.stylix = with config.lib.stylix.colors.withHashtag; {
          name = "stylix";
          description = "Stylix base16 palette";

          colors = {
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
        };
      };
    };
}
