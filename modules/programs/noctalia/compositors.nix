{
  profiles.pc.homeModule = {
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

    wayland.windowManager.niri.settings._children = [
      {
        window-rule = {
          match._props.app-id = "^dev\\.noctalia\\.Noctalia$";
          open-floating = true;
          default-column-width.fixed = 1080;
          default-window-height.fixed = 920;
        };
      }
    ];
  };
}
