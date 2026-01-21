{
  flake.modules = {
    homeManager.default = {
      wayland.windowManager.hyprland.settings = {
        exec-once = map (app: "uwsm app -- ${app}") [
          "code-insiders"
          "helium"

          "spotify"
          "vesktop"

          "1password --silent"
        ];

        windowrule = [
          "match:class code-insiders, workspace 1 silent"
          "match:class helium, workspace 1 silent"

          "match:class Spotify, workspace 2 silent"
          "match:class vesktop, workspace 2 silent"
        ];
      };
    };
  };
}
