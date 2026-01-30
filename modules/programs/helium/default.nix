{
  flake.modules.homeManager.default = {
    programs.helium.enable = true;

    wayland.windowManager.hyprland.settings.bind = [
      "SUPER, B, exec, uwsm app -- helium"
    ];

    persist.directories = [ ".config/net.imput.helium" ];
  };
}
