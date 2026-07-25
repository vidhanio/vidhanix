{ lib, ... }:
let
  bind = keys: dispatcher: {
    _args = [
      keys
      (lib.generators.mkLuaInline dispatcher)
    ];
  };
in
{
  flake.modules = {
    homeManager.default = {
      wayland.windowManager.hyprland.extraLuaFiles."cycle-workspace" = {
        content = ./cycle-workspace.lua;
        autoLoad = true;
      };

      wayland.windowManager.hyprland.settings = {
        gesture = {
          fingers = 3;
          direction = "horizontal";
          action = "workspace";
        };

        bind =
          let
            workspaceBindings =
              i:
              let
                istr = toString i;
              in
              [
                # Switch to workspace i
                (bind "SUPER + ${istr}" "hl.dsp.focus({ workspace = ${istr}, on_current_monitor = true })")
                # Move focused window to workspace i
                (bind "SUPER + SHIFT + ${istr}" "hl.dsp.window.move({ workspace = ${istr}, follow = false })")
              ];
          in

          lib.concatMap workspaceBindings (lib.range 1 9)
          ++ [
            # Special workspace (scratchpad)
            (bind "SUPER + S" "hl.dsp.workspace.toggle_special()")
            (bind "SUPER + SHIFT + S" ''hl.dsp.window.move({ workspace = "special" })'')
          ];
      };
    };
  };

  configurations.vidhan-pc.homeModule = {
    wayland.windowManager.hyprland.settings.bind = lib.mkAfter [
      (bind "SUPER + grave" ''hl.dsp.workspace.swap_monitors({ monitor1 = "current", monitor2 = "+1" })'')
      (bind "SUPER + SHIFT + grave" ''hl.dsp.focus({ monitor = "+1" })'')
    ];
  };
}
