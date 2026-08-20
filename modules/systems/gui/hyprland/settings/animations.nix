{
  flake.aspects.hyprland = {
    homeManager = {
      wayland.windowManager.hyprland.settings = {
        curve = [
          {
            _args = [
              "easeOutQuint"
              {
                type = "bezier";
                points = [
                  [
                    0.22
                    1
                  ]
                  [
                    0.32
                    1
                  ]
                ];
              }
            ];
          }
        ];
        animation = [
          {
            leaf = "global";
            enabled = true;
            speed = 2.5;
            bezier = "easeOutQuint";
          }
          {
            leaf = "specialWorkspaceIn";
            enabled = true;
            speed = 2.5;
            bezier = "easeOutQuint";
            style = "slidevert top";
          }
          {
            leaf = "specialWorkspaceOut";
            enabled = true;
            speed = 2.5;
            bezier = "easeOutQuint";
            style = "slidevert bottom";
          }
        ];
      };
    };
  };
}
