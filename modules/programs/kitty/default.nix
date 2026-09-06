{
  flake.aspects.kitty = {
    homeManager = { config, ... }: {
      home.sessionVariables.TERMINAL = "kitty";
      programs.kitty = {
        enable = true;
        settings = {
          confirm_os_window_close = 0;
          window_padding_width = config.stylix.padding;
        };
      };

      xdg.autostart.entries = [
        "${config.programs.kitty.package}/share/applications/kitty.desktop"
      ];

      wayland.windowManager.hyprland.autostartWorkspaces.kitty = 1;

      binds."SUPER + T".app = "kitty --single-instance";
    };
  };
}
