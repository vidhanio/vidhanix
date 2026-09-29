{
  flake.aspects.niri.homeManager =
    { config, ... }:
    let
      colors = config.lib.stylix.colors.withHashtag;
      innerPadding = builtins.div config.stylix.padding 2;
    in
    {
      wayland.windowManager.niri.settings = {
        layout = {
          gaps = innerPadding;
          struts = {
            left = innerPadding;
            right = innerPadding;
            top = innerPadding;
            bottom = innerPadding;
          };

          focus-ring.off = { };
          border = {
            on = { };
            width = config.stylix.borderThickness;
            active-color = colors.base0D;
            inactive-color = colors.base03;
            urgent-color = colors.base08;
          };

          shadow.off = { };
        };
        overview.backdrop-color = colors.base00;
      };
    };
}
