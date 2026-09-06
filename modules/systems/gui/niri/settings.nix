{ lib, ... }:
let
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
  flake.aspects.niri.homeManager =
    {
      config,
      osConfig,
      ...
    }:
    let
      colors = config.lib.stylix.colors.withHashtag;
      monitors = osConfig.hardware.monitors;
      innerPadding = builtins.div config.stylix.padding 2;
    in
    {
      wayland.windowManager.niri.settings = {
        input = {
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
          gaps = innerPadding;
          struts = {
            left = innerPadding;
            right = innerPadding;
            top = innerPadding;
            bottom = innerPadding;
          };

          focus-ring.off = { };
          border = {
            on = { };
            width = config.stylix.borderThickness;
            active-color = colors.base0D;
            inactive-color = colors.base03;
            urgent-color = colors.base08;
          };

          shadow.off = { };
        };

        prefer-no-csd = { };

        _children = [
          (renderOutput true monitors.main)
          {
            window-rule = {
              geometry-corner-radius = config.stylix.cornerRadius;
              clip-to-geometry = true;
            };
          }
          {
            window-rule = {
              match._props.app-id = "^dev\\.noctalia\\.Noctalia$";
              open-floating = true;
              default-column-width.fixed = 1080;
              default-window-height.fixed = 920;
            };
          }
        ]
        ++ map (renderOutput false) monitors.others;
      };
    };
}
