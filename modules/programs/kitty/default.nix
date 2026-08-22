{
  flake.aspects.kitty = {
    homeManager = { config, ... }: {
      programs.kitty = {
        enable = true;
        settings =
          let
            padding = 8;
          in
          {
            # One value sets all four sides (kitty's padding option).
            window_padding_width = padding;
          };
      };

      xdg.autostart.entries = [
        "${config.programs.kitty.package}/share/applications/kitty.desktop"
      ];

      wayland.windowManager.hyprland.autostartWorkspaces.kitty = 1;

      # Open a new window in the autostarted instance when one is running.
      wayland.windowManager.hyprland.binds."SUPER + T".exec_cmd = "kitty --single-instance";
    };
  };
}
