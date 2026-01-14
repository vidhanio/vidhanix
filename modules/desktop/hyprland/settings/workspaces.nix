{
  flake.modules = {
    homeManager.default = {
      wayland.windowManager.hyprland.settings = {
        gesture = "3, horizontal, workspace";

        bind = [
          # Switch workspaces
          "SUPER, 1, workspace, name:main"
          "SUPER, 2, workspace, name:games"

          # Special workspace (scratchpad)
          "SUPER, S, togglespecialworkspace"
          "SUPER SHIFT, S, movetoworkspace, special"

          # Scroll through existing workspaces with SUPER + scroll
          "SUPER, mouse_down, workspace, e+1"
          "SUPER, mouse_up, workspace, e-1"
        ];
      };
    };
  };
}
