{
  flake.modules.homeManager.default = {
    programs.ghostty = {
      settings =
        let
          padding = 10;
        in
        {
          window-padding-x = padding;
          window-padding-y = padding;
        };
    };
  };
}
