{
  profiles.pc = {
    module.programs.niri.enable = true;
    homeModule =
      { config, ... }:
      {
        wayland.windowManager.niri = {
          enable = true;
          settings = {
            prefer-no-csd = { };
            hotkey-overlay.skip-at-startup = { };
            cursor = {
              xcursor-theme = config.home.pointerCursor.name;
              xcursor-size = config.home.pointerCursor.size;
            };
            input = {
              # Preserve Niri's built-in Mod+MouseLeft drag and Mod+MouseRight resize gestures.
              mod-key = "Super";
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
            layout = {
              focus-ring.off = { };
              border.on = { };
              shadow.off = { };
            };
          };
        };
      };
  };
}
