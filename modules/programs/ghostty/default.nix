{
  flake.modules.homeManager.default = {
    programs.ghostty = {
      enable = true;
      settings =
        let
          padding = 10;

          bind = key: action: "${key}=${action}";
          gotoSplit = dir: bind "alt+${dir}" "goto_split:${dir}";
          newSplit = dir: bind "alt+shift+${dir}" "new_split:${dir}";

          dirs = {
            up = "up";
            down = "down";
            left = "left";
            right = "right";
            h = "left";
            j = "down";
            k = "up";
            l = "right";
          };
        in
        {
          window-padding-x = padding;
          window-padding-y = padding;

          keybind =
            # keep-sorted start
            (map gotoSplit (builtins.attrValues dirs))
            ++ (map newSplit (builtins.attrValues dirs))
            # keep-sorted end
            ++ [
              (bind "alt+tab" "goto_split:next")
              (bind "alt+shift+tab" "goto_split:previous")
              (bind "alt+enter" "new_split:auto")
            ];
        };
    };

    wayland.windowManager.hyprland.settings.bind = [
      "SUPER, T, exec, uwsm app -- ghostty"
    ];
  };
}
