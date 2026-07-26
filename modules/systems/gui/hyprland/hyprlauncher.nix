{ lib, ... }:
{
  den.default.homeManager = {
    services.hyprlauncher.enable = true;

    wayland.windowManager.hyprland.settings.bind = [
      {
        _args = [
          "SUPER + E"
          (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("uwsm app -- hyprlauncher")'')
        ];
      }
    ];
  };
}
