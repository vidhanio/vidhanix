{
  flake.aspects.kitty = {
    homeManager = { config, ... }: {
      programs.kitty = {
        enable = true;
        settings = {
          confirm_os_window_close = 0;
          window_padding_width = 8;
        };
      };

      xdg.autostart.entries = [
        "${config.programs.kitty.package}/share/applications/kitty.desktop"
      ];

      wayland.windowManager.hyprland.autostartWorkspaces.kitty = 1;

      wayland.windowManager.hyprland.binds."SUPER + T".exec_cmd = "kitty --single-instance";
    };
  };
}
