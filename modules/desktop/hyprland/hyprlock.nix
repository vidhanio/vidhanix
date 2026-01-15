{
  flake.modules.homeManager.default = {
    programs.hyprlock.enable = true;

    wayland.windowManager.hyprland.settings = {
      bind = [
        "SUPER, L, exec, uwsm app -- hyprlock"
      ];
    };
  };
}
