{
  flake.aspects.hyprland = {
    homeManager =
      { pkgs, ... }:
      let
        lua = pkgs.formats.lua { };
      in
      {
        xdg.configFile."hypr/hyprsplit/init.lua".source = "${pkgs.hyprlandPlugins.hyprsplit.src}/init.lua";
        wayland.windowManager.hyprland = {
          # TODO: https://github.com/nix-community/home-manager/pull/9918
          # extraLuaFiles."hyprsplit/init" = {
          #   autoLoad = false;
          #   path = "${pkgs.hyprlandPlugins.hyprsplit.src}/init.lua";
          # };

          settings = {
            hs._var = lua.lib.mkRaw ''require("hyprsplit")'';

            gesture = [
              {
                fingers = 3;
                direction = "horizontal";
                action = "workspace";
              }
              {
                fingers = 3;
                direction = "down";
                action = lua.lib.mkRaw ''
                  function()
                    if hl.get_active_special_workspace() == nil then
                      hl.dispatch(hl.dsp.workspace.toggle_special())
                    end
                  end
                '';
              }
              {
                fingers = 3;
                direction = "up";
                action = lua.lib.mkRaw ''
                  function()
                    if hl.get_active_special_workspace() ~= nil then
                      hl.dispatch(hl.dsp.workspace.toggle_special())
                    end
                  end
                '';
              }
            ];

            config.binds.hide_special_on_workspace_change = true;
          };
        };

        binds = {
          "SUPER + s".hyprland.dsp."workspace.toggle_special" = { };
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
