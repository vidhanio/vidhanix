{
  flake.modules.homeManager.default =
    { config, ... }:
    {
      programs.ghostty = {
        enable = true;
        settings =
          let
            padding = 10;
          in
          {
            window-padding-x = padding;
            window-padding-y = padding;
            background-opacity-cells = true;
          };
      };

      xdg.autostart.entries = [
        "${config.programs.ghostty.package}/share/applications/com.mitchellh.ghostty.desktop"
      ];

      hyprland.autostartWorkspaces.ghostty = 1;

      hyprland.binds."SUPER + T".exec_cmd = "uwsm app -- ghostty";
    };
}
