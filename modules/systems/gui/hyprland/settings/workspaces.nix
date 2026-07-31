{ lib, ... }:
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
      };

      hyprland.binds =
        lib.mergeAttrsList (
          map (i: {
            # Switch to workspace i
            "SUPER + ${toString i}".focus = {
              workspace = i;
              on_current_monitor = true;
            };
            # Move focused window to workspace i
            "SUPER + SHIFT + ${toString i}"."window.move" = {
              workspace = i;
              follow = false;
            };
          }) (lib.range 1 9)
        )
        // {
          # Special workspace (scratchpad)
          "SUPER + S"."workspace.toggle_special" = { };
          "SUPER + SHIFT + S"."window.move".workspace = "special";

          # Monitors
          "SUPER + grave"."workspace.swap_monitors" = {
            monitor1 = "current";
            monitor2 = "+1";
          };
          "SUPER + SHIFT + grave".focus.monitor = "+1";
        };
    };
  };
}
