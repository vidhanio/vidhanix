{
  flake.aspects.hyprland = {
    homeManager = {
      wayland.windowManager.hyprland.settings = {
        config = {
          ecosystem = {
            no_update_news = true;
            no_donation_nag = true;
          };

          misc = {
            disable_splash_rendering = true;
          };

          xwayland = {
            force_zero_scaling = true;
          };
        };
      };
    };
  };
}
