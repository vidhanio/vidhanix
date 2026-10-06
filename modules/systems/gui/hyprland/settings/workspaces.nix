{
  profiles.pc = {
    homeModule =
      { pkgs, ... }:
      let
        lua = pkgs.formats.lua { };
      in
      {
        wayland.windowManager.hyprland = {
          extraLuaFiles = {
            "hyprsplit/init" = {
              autoLoad = false;
              content = "${pkgs.hyprlandPlugins.hyprsplit.src}/init.lua";
            };
            scrolling-gesture = {
              autoLoad = false;
              content = ./scrolling-gesture.lua;
            };
          };

          settings = {
            hs._var = lua.lib.mkRaw ''require("hyprsplit")'';

            gesture = [
              {
                fingers = 3;
                direction = "vertical";
                action = "workspace";
              }
              {
                fingers = 3;
                direction = "horizontal";
                action = lua.lib.mkRaw ''require("scrolling-gesture")'';
              }
            ];

            config.binds.hide_special_on_workspace_change = true;
          };
        };

        desktop.binds = {
          "SUPER + SHIFT + s".hyprland.dsp."window.move" = {
            workspace = "special";
            follow = false;
          };
          "SUPER + grave".hyprland.lua =
            ''hs.dsp.workspace.swap_monitors({ monitor1 = "current", monitor2 = "+1" })'';
        };
      };
  };
}
