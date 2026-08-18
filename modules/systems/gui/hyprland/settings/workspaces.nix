{ lib, ... }:
{
  flake.aspects.hyprland = {
    homeManager = {
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
            "SUPER + ${toString i}".focus = {
              workspace = i;
              on_current_monitor = true;
            };
            "SUPER + SHIFT + ${toString i}"."window.move" = {
              workspace = i;
              follow = false;
            };
          }) (lib.range 1 9)
        )
        // {
          # Scratchpad
          "SUPER + S"."workspace.toggle_special" = { };
          "SUPER + SHIFT + S"."window.move".workspace = "special";

          "SUPER + grave"."workspace.swap_monitors" = {
            monitor1 = "current";
            monitor2 = "+1";
          };
          "SUPER + SHIFT + grave".focus.monitor = "+1";
        };
    };
  };
}
