{ lib, ... }:
{
  profiles.pc.homeModule =
    {
      config,
      osConfig,
      pkgs,
      ...
    }:
    let
      lua = pkgs.formats.lua { };
      monitors = [ osConfig.hardware.monitors.main ] ++ osConfig.hardware.monitors.others;
      workspaces = lib.mapAttrsToList (
        name: workspace:
        let
          output =
            if workspace.output == null then osConfig.hardware.monitors.main.name else workspace.output;
          monitorIndex = lib.lists.findFirstIndex (monitor: monitor.name == output) null monitors;
        in
        workspace
        // {
          inherit name output;
          selector = toString (monitorIndex * 10 + workspace.index);
        }
      ) config.desktop.workspaces;
      toLua = lib.generators.toLua { };
      renderRule = workspace: {
        workspace = workspace.selector;
        monitor = workspace.output;
        default_name = workspace.name;
        persistent = true;
        default = workspace.index == 1;
      };
      startupRules = lib.concatMap (
        workspace:
        map (app: {
          name = "desktop-startup-${workspace.name}-${app}";
          match.class = "^${lib.escapeRegex app}$";
          workspace = "${workspace.selector} silent";
        }) workspace.apps
      ) workspaces;
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
          workspace_rule = lib.mkAfter (map renderRule workspaces);
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
        extraConfig = lib.optionalString (startupRules != [ ]) ''
          local startup_path = os.getenv("XDG_RUNTIME_DIR") .. "/hypr/"
            .. os.getenv("HYPRLAND_INSTANCE_SIGNATURE") .. "/desktop-workspaces-startup"
          local startup_file = io.open(startup_path, "r")
          local startup_time
          if startup_file then
            startup_time = tonumber(startup_file:read("*a"))
            startup_file:close()
          else
            startup_time = os.time()
            startup_file = assert(io.open(startup_path, "w"))
            startup_file:write(tostring(startup_time))
            startup_file:close()
          end
          local remaining = math.max(0, 60 - (os.time() - startup_time)) * 1000
          local desktop_startup_rules = {}
          for _, rule in ipairs(${toLua startupRules}) do
            table.insert(desktop_startup_rules, hl.window_rule(rule))
            if remaining == 0 then
              desktop_startup_rules[#desktop_startup_rules]:set_enabled(false)
            end
          end
          if remaining > 0 then
            hl.timer(function()
              for _, rule in ipairs(desktop_startup_rules) do
                rule:set_enabled(false)
              end
            end, { timeout = remaining, type = "oneshot" })
          end
        '';
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
}
