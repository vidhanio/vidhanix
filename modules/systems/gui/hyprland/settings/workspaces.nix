{ lib, ... }:
{
  flake.modules = {
    homeManager.default = {
      wayland.windowManager.hyprland.settings = {
        gesture = "3, horizontal, workspace";

        bind =
          let
            workspaceBindings =
              i:
              let
                istr = toString i;
              in
              [
                # Switch to workspace i
                "SUPER, ${istr}, focusworkspaceoncurrentmonitor, ${istr}"
                # Move focused window to workspace i
                "SUPER SHIFT, ${istr}, movetoworkspacesilent, ${istr}"
              ];
          in

          lib.concatMap workspaceBindings (lib.range 1 9)
          ++ [
            # Special workspace (scratchpad)
            "SUPER, S, togglespecialworkspace"
            "SUPER SHIFT, S, movetoworkspace, special"

            # Scroll through existing workspaces with SUPER + scroll
            "SUPER, mouse_down, workspace, m+1"
            "SUPER, mouse_up, workspace, m-1"
          ];
      };
    };
  };
}
