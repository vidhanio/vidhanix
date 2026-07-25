{ lib, ... }:
let
  bind = keys: dispatcher: {
    _args = [
      keys
      (lib.generators.mkLuaInline dispatcher)
      { locked = true; }
    ];
  };
in
{
  flake.modules = {
    nixos.default = {
      services.playerctld.enable = true;
    };
    homeManager.default = {
      wayland.windowManager.hyprland.settings.bind = [
        (bind "XF86AudioPrev" ''hl.dsp.exec_cmd("playerctl previous")'')
        (bind "XF86AudioNext" ''hl.dsp.exec_cmd("playerctl next")'')
        (bind "XF86AudioPause" ''hl.dsp.exec_cmd("playerctl play-pause")'')
        (bind "XF86AudioPlay" ''hl.dsp.exec_cmd("playerctl play-pause")'')
      ];
    };
  };
}
