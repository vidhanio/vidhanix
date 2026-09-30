{
  flake.aspects.hyprland.homeManager = { config, ... }: {
    wayland.windowManager.hyprland.settings.config = {
      general = {
        border_size = config.stylix.borderThickness;
        gaps_in = builtins.div config.stylix.padding 2;
        gaps_out = config.stylix.padding;
        layout = "scrolling";
      };
      decoration = {
        rounding = config.stylix.cornerRadius;
        blur =
          let
            vibrancy = if config.stylix.polarity == "dark" then 0.5 else 0;
          in
          {
            size = 2;
            passes = 3;
            inherit vibrancy;
            vibrancy_darkness = vibrancy;
          };
        shadow.enabled = false;
      };
    };
  };
}
