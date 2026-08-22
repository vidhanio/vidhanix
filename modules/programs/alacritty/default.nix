{
  flake.aspects.alacritty = {
    homeManager = {
      programs.alacritty = {
        enable = true;
        settings = {
          window.padding =
            let
              padding = 8;
            in
            {
              x = padding;
              y = padding;
            };
        };
      };
    };
  };
}
