{ lib, ... }:
let
  bind = keys: dispatcher: {
    _args = [
      keys
      (lib.generators.mkLuaInline dispatcher)
    ];
  };
  mouseBind = keys: dispatcher: {
    _args = [
      keys
      (lib.generators.mkLuaInline dispatcher)
      (lib.generators.mkLuaInline "{ mouse = true }")
    ];
  };
in
{
  flake.modules = {
    homeManager.default =
      { pkgs, ... }:
      {
        wayland.windowManager.hyprland.settings.bind = [
          (bind "SUPER + Q" "hl.dsp.window.close()")
          (bind "SUPER + M" ''hl.dsp.exec_cmd("uwsm stop")'')
          (bind "SUPER + V" ''hl.dsp.exec_cmd("noctalia msg panel-toggle clipboard")'')
          (bind "SUPER + J" ''hl.dsp.layout("togglesplit")'')
          (bind "SUPER + F" "hl.dsp.window.fullscreen()")

          # screenshot
          (bind "Print" ''hl.dsp.exec_cmd("${lib.getExe pkgs.grimblast} --freeze copy area")'')
          (bind "SHIFT + Print" ''hl.dsp.exec_cmd("${lib.getExe pkgs.hyprpicker} -a")'')

          # move/resize windows with SUPER + LMB/RMB and dragging
          (mouseBind "SUPER + mouse:272" "hl.dsp.window.drag()")
          (mouseBind "SUPER + mouse:273" "hl.dsp.window.resize()")
        ];
      };
  };
}
