{
  flake.aspects.noctalia.homeManager = {
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
