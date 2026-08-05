{
  flake.modules.homeManager.default = {
    programs.ghostty = {
      enable = true;
      settings =
        let
          padding = 10;
        in
        {
          window-padding-x = padding;
          window-padding-y = padding;
          background-opacity-cells = true;
        };
    };

    hyprland.autostartWorkspaces.ghostty = 1;

    hyprland.binds."SUPER + T".exec_cmd = "uwsm app -- ghostty";
  };
}
