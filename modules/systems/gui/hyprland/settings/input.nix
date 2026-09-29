{
  flake.aspects.hyprland.homeManager = {
    wayland.windowManager.hyprland.settings.config.input = {
      repeat_rate = 50;
      repeat_delay = 500;
      touchpad = {
        natural_scroll = true;
        clickfinger_behavior = true;
      };
    };
  };
}
