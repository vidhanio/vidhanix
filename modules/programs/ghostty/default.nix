{ lib, ... }:
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
          };
      };

      xdg.autostart.entries = [
        "${config.programs.ghostty.package}/share/applications/com.mitchellh.ghostty.desktop"
      ];

      hyprland.autostartWorkspaces.ghostty = 1;

      wayland.windowManager.hyprland.settings.bind = [
        {
          _args = [
            "SUPER + T"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("uwsm app -- ghostty")'')
          ];
        }
      ];
    };
}
