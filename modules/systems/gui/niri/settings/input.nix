{
  flake.aspects.niri.homeManager = {
    wayland.windowManager.niri.settings.input = {
      focus-follows-mouse = { };
      keyboard = {
        repeat-delay = 500;
        repeat-rate = 50;
      };
      touchpad = {
        natural-scroll = { };
        click-method = "clickfinger";
      };
    };
  };
}
