{
  profiles.pc.homeModule = {
    wayland.windowManager.hyprland.settings = {
      config = {
        general.allow_tearing = true;
        render.direct_scanout = 1;
      };

      window_rule = [
        {
          name = "gd-hyprland-tearing";
          match.class = "^steam_app_322170$";
          immediate = true;
        }
      ];
    };
  };
}
