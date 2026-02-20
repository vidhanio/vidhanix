{
  flake.modules = {
    homeManager.default = {
      wayland.windowManager.hyprland.settings = {
        exec-once = map (app: "uwsm app -- ${app}") [
          "ghostty"
          "helium"

          "spotify"
          "vesktop"
        ];
      };
    };
  };
}
