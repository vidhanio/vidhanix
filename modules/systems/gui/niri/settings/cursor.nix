{
  flake.aspects.niri.homeManager = { config, ... }: {
    wayland.windowManager.niri.settings.cursor = {
      xcursor-theme = config.home.pointerCursor.name;
      xcursor-size = config.home.pointerCursor.size;
    };
  };
}
