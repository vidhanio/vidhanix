{ lib, ... }:
{
  profiles.pc.homeModule =
    {
      osConfig,
      ...
    }:
    let
      monitors = osConfig.hardware.monitors;

      renderMode =
        monitor:
        if monitor.mode == null then
          null
        else
          "${toString monitor.mode.width}x${toString monitor.mode.height}@${lib.strings.floatToString monitor.mode.refreshRate}";

      renderOutput = isMain: monitor: {
        output = {
          _args = [ monitor.name ];
          inherit (monitor) scale;
          position._props = {
            inherit (monitor.position) x y;
          };
          variable-refresh-rate = { };
        }
        // lib.optionalAttrs (monitor.mode != null) {
          mode = renderMode monitor;
        }
        // lib.optionalAttrs isMain {
          focus-at-startup = { };
        };
      };
    in
    {
      wayland.windowManager.niri.settings._children = [
        (renderOutput true monitors.main)
      ]
      ++ map (renderOutput false) monitors.others;
    };
}
