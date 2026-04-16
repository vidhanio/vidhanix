{
  flake.modules.homeManager.default =
    { config, ... }:
    {
      programs.helium.enable = true;

      xdg.autostart.entries = [ "${config.programs.helium.package}/share/applications/helium.desktop" ];

      hyprland.autostartWorkspaces.helium = 1;

      wayland.windowManager.hyprland.settings.bind = [
        "SUPER, B, exec, uwsm app -- helium"
      ];

      persist.directories = [ ".config/net.imput.helium" ];
    };
}
