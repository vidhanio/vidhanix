{
  flake.aspects.hyprland.homeManager = {
    wayland.windowManager.hyprland.settings = {
      window_rule = [
        {
          match = {
            workspace = "f[1]";
            float = false;
          };

          rounding = 0;
          border_size = 0;
        }
      ];

      workspace_rule = [
        {
          workspace = "f[1]";
          gaps_in = 0;
          gaps_out = 0;
        }
      ];
    };
  };
}
