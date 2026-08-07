{
  flake.modules.homeManager.default = {
    home.shellAliases.z = "zellij";

    programs.zellij = {
      enable = true;
      settings = {
        simplified_ui = true;
        ui.pane_frames.hide_session_name = true;
      };
      layouts = {
        default.layout = {
          _children = [
            {
              default_tab_template = {
                _children = [
                  {
                    pane = {
                      size = 1;
                      borderless = true;
                      plugin.location = "zellij:tab-bar";
                    };
                  }
                  { children = { }; }
                ];
              };
            }
            {
              tab = {
                _props = {
                  name = "AI";
                  focus = true;
                };
                _children = [
                  {
                    pane = {
                      command = "opencode";
                    };
                  }
                  {
                    pane.size = "30%";
                  }
                ];
              };
            }
            {
              tab = {
                _props.name = "Git";
                _children = [
                  {
                    pane.command = "lazygit";
                  }
                ];
              };
            }
            {
              tab = {
                _props.name = "Editor";
                _children = [
                  {
                    pane.edit = ".";
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
