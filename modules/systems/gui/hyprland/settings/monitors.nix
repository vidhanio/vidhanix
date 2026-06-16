{ lib, ... }:
let
  renderRefreshRate = refreshRate: lib.strings.floatToString refreshRate;
  renderScale = scale: lib.strings.floatToString scale;
  renderMode =
    monitor:
    if monitor.mode == null then
      "preferred"
    else
      "${toString monitor.mode.width}x${toString monitor.mode.height}@${renderRefreshRate monitor.mode.refreshRate}";
  renderMonitor =
    monitor:
    "${monitor.name}, ${renderMode monitor}, ${toString monitor.position.x}x${toString monitor.position.y}, ${renderScale monitor.scale}";
  renderMonitors = monitors: map renderMonitor ([ monitors.main ] ++ monitors.others);
in
{
  flake.modules.homeManager.default = { osConfig, ... }: {
    wayland.windowManager.hyprland.settings = {
      monitor = renderMonitors osConfig.hardware.monitors;

      misc.vrr = 1;
    };
  };
}
