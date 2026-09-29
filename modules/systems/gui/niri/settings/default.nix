{
  flake.aspects.niri.homeManager = {
    wayland.windowManager.niri.settings = {
      prefer-no-csd = { };
      hotkey-overlay.skip-at-startup = { };
    };
  };
}
