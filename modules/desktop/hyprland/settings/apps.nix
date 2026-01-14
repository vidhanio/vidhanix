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

          workspace = [
            "name:games, on-created-empty:${uwsmApp "steam"}"
          ];

          windowrule = [
            "match:class code-insiders, workspace name:main silent"
            "match:class helium, workspace name:main silent"

            "match:class spotify, workspace name:side silent"
            "match:class vesktop, workspace name:side silent"
          ];

          bind = [
            "SUPER, T, exec, ${uwsmApp "ghostty"}"
            "SUPER, Space, exec, ${uwsmApp "hyprlauncher"}"
          ];
        };
    };
  };
}
