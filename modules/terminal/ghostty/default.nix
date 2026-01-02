{
  flake.modules.homeManager.default = {
    programs.ghostty = {
      enable = true;
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
