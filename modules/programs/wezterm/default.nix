{
  flake.aspects.wezterm = {
    homeManager = {
      programs.wezterm = {
        enable = true;
        settings = {
          hide_tab_bar_if_only_one_tab = true;
          window_padding =
            let
              padding = 8;
            in
            {
              left = padding;
              right = padding;
              top = padding;
              bottom = padding;
            };
        };
      };
    };
  };
}
