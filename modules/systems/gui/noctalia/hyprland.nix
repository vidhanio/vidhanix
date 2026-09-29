{
  flake.aspects.noctalia.homeManager = {
    wayland.windowManager.hyprland.settings = {
      window_rule = [
        {
          match.class = "dev.noctalia.Noctalia";

          float = true;
          size = [
            1080
            920
          ];
        }
      ];

      layer_rule = [
        {
          name = "noctalia";
          match.namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$";

          no_anim = true;
          ignore_alpha = 0;
          blur = true;
          blur_popups = true;
        }
      ];
    };
  };
}
