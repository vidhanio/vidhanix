{
  flake.aspects.kitty = {
    homeManager = { config, ... }: {
      programs.kitty = {
        enable = true;
        settings = {
          window_padding_width = 8;
        };
      };

      xdg.autostart.entries = [
        "${config.programs.kitty.package}/share/applications/kitty.desktop"
      ];

      wayland.windowManager.hyprland.autostartWorkspaces.kitty = 1;
    };
  };
}
