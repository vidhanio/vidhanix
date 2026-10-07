{
  profiles.pc = {
    homeModule = {
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
          {
            _args = [
              "niriScroll"
              {
                type = "spring";
                stiffness = 800;
                # Critical damping: 2 * sqrt(stiffness * mass).
                damping = 56.568542494923804;
                mass = 1;
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
            leaf = "windowsMove";
            enabled = true;
            spring = "niriScroll";
            speed = 1;
          }
          {
            leaf = "workspaces";
            enabled = true;
            speed = 2.5;
            bezier = "easeOutQuint";
            style = "slidevert";
          }
          {
            leaf = "workspacesIn";
            enabled = true;
            speed = 2.5;
            bezier = "easeOutQuint";
            style = "slidevert";
          }
          {
            leaf = "workspacesOut";
            enabled = true;
            speed = 2.5;
            bezier = "easeOutQuint";
            style = "slidevert";
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
