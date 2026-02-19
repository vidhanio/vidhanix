{
  flake.modules.homeManager.default = {
    services.hyprlauncher.enable = true;

    wayland.windowManager.hyprland.settings.bind = [
      "SUPER, E, exec, uwsm app -- hyprlauncher"
    ];
  };
}
