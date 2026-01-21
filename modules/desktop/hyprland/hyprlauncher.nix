{
  flake.modules.homeManager.default = {
    services.hyprlauncher.enable = true;

    wayland.windowManager.hyprland.settings.bind = [
      "SUPER, Space, exec, uwsm app -- hyprlauncher"
    ];
  };
}
