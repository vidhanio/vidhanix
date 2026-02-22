{
  flake.modules.homeManager.default = {
    programs.zellij = {
      enable = true;
      layouts = {
        default.layout = {
          _children = [
            {
              default_tab_template = {
                _children = [
                  { children = { }; }
                  {
                    pane = {
                      size = 1;
                      borderless = true;
                      plugin.location = "zellij:compact-bar";
                    };
                  }
                ];
              };
            }
            {
              tab = {
                _props = {
                  name = "Vibe";
                  focus = true;
                };
                _children = [
                  {
                    pane = {
                      _props.split_direction = "vertical";
                      _children = [
                        {
                          pane = {
                            command = "opencode";
                            size = "40%";
                          };
                        }
                        {
                          pane = {
                            command = "lazygit";
                            size = "60%";
                          };
                        }
                      ];
                    };
                  }
                ];
              };
            }
            {
              tab = {
                _props.name = "Editor";
                _children = [
                  {
                    pane = {
                      command = "nvim";
                      args = ".";
                    };
                  }
                ];
              };
            }
            {
              tab = {
                _props.name = "Shell";
                _children = [
                  {
                    pane = { };
                  }
                ];
              };
            }
          ];
        };

      };
    };
  };
}
