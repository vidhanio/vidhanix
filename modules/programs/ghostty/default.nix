{
  flake.aspects.ghostty = {
    homeManager = { config, ... }: {
      programs.ghostty = {
        enable = true;
        settings =
          let
            padding = 8;
          in
          {
            window-padding-x = padding;
            window-padding-y = padding;
            background-opacity-cells = true;

            # stay resident with no windows open; new windows then take the fast path.
            quit-after-last-window-closed = false;
          };
      };

      xdg.autostart.entries = [
        "${config.programs.ghostty.package}/share/applications/com.mitchellh.ghostty.desktop"
      ];

      wayland.windowManager.hyprland.autostartWorkspaces.ghostty = 1;

      wayland.windowManager.hyprland.binds."SUPER + T".exec_cmd = "ghostty +new-window";
    };
  };
}
