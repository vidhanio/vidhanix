{
  flake.modules = {
    homeManager.default = {
      wayland.windowManager.hyprland.settings =
        let
          uwsmApp = app: "uwsm app -- ${app}";
        in
        {
          exec-once = map uwsmApp [
            "code-insiders"
            "helium"

            "spotify"
            "vesktop"

            "steam -silent"
            "1password --silent"
          ];

          windowrule = [
            "match:class code-insiders, workspace 1 silent"
            "match:class helium, workspace 1 silent"

            "match:class Spotify, workspace 2 silent"
            "match:class vesktop, workspace 2 silent"
          ];

          bind = [
            "SUPER, T, exec, ${uwsmApp "ghostty"}"
            "SUPER, Space, exec, ${uwsmApp "hyprlauncher"}"
          ];
        };
    };
  };
}
