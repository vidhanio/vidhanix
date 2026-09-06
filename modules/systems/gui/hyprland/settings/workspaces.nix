{ lib, ... }:
{
  flake.aspects.hyprland = {
    homeManager =
      { pkgs, ... }:
      let
        lua = pkgs.formats.lua { };
      in
      {
        wayland.windowManager.hyprland = {
          extraLuaFiles."cycle-workspace" = {
            content = ./cycle-workspace.lua;
            autoLoad = true;
          };

          settings = {
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

        binds =
          lib.mergeAttrsList (
            map (i: {
              "SUPER + ${toString i}".hyprland.dsp.focus = {
                workspace = i;
                on_current_monitor = true;
              };
              "SUPER + SHIFT + ${toString i}".hyprland.dsp."window.move" = {
                workspace = i;
                follow = false;
              };
            }) (lib.range 1 9)
          )
          // {
            "SUPER + S".hyprland.dsp."workspace.toggle_special" = { };
            "SUPER + SHIFT + S".hyprland.dsp."window.move" = {
              workspace = "special";
              follow = false;
            };

            "SUPER + grave".hyprland.dsp."workspace.swap_monitors" = {
              monitor1 = "current";
              monitor2 = "+1";
            };
            "SUPER + SHIFT + grave".hyprland.dsp.focus.monitor = "+1";
          };
      };
  };
}
