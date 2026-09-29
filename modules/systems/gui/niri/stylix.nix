{
  flake.aspects.niri.homeManager =
    { config, lib, ... }:
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
          border = {
            width = config.stylix.borderThickness;
            active-color = colors.base0D;
            inactive-color = colors.base03;
            urgent-color = colors.base08;
          };
        };
        overview.backdrop-color = colors.base00;
        _children = lib.mkBefore [
          {
            window-rule = {
              geometry-corner-radius = config.stylix.cornerRadius;
              clip-to-geometry = true;
            };
          }
        ];
      };
    };
}
