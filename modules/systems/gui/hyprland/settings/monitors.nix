{ lib, ... }:
let
  renderMode =
    monitor:
    if monitor.mode == null then
      "preferred"
    else
      "${toString monitor.mode.width}x${toString monitor.mode.height}@${lib.strings.floatToString monitor.mode.refreshRate}";
  renderMonitor = monitor: {
    output = monitor.name;
    mode = renderMode monitor;
    position = "${toString monitor.position.x}x${toString monitor.position.y}";
    scale = lib.strings.floatToString monitor.scale;
  };
  renderMonitors = monitors: map renderMonitor ([ monitors.main ] ++ monitors.others);
in
{
  den.default.homeManager =
    { osConfig, ... }:
    {
      wayland.windowManager.hyprland.settings = {
        monitor = renderMonitors osConfig.hardware.monitors;

        config.misc.vrr = 1;
      };
    };
}
