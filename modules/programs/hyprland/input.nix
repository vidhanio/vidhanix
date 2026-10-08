{
  profiles.pc.homeModule = {
    wayland.windowManager.hyprland.settings.config = {
      # `SUPER + wheel` scrubs the tape, so drop the 300ms wheel bind throttle
      binds.scroll_event_delay = 50;
      input = {
        repeat_rate = 50;
        repeat_delay = 500;
        touchpad = {
          natural_scroll = true;
          clickfinger_behavior = true;
        };
      };
    };
  };
}
