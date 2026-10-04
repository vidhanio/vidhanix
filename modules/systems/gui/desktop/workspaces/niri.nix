{ lib, ... }:
{
  flake.aspects.desktop.homeManager =
    { config, osConfig, ... }:
    let
      workspaces = lib.mapAttrsToList (
        name: workspace:
        workspace
        // {
          inherit name;
          output =
            if workspace.output == null then osConfig.hardware.monitors.main.name else workspace.output;
        }
      ) (lib.filterAttrs (_: workspace: !workspace.special) config.desktop.workspaces);
      ordered = lib.sort (
        a: b: if a.output == b.output then a.index < b.index else a.output < b.output
      ) workspaces;
      renderWorkspace = workspace: {
        workspace = {
          _args = [ workspace.name ];
          open-on-output = workspace.output;
        };
      };
      renderRules =
        workspace:
        map (app: {
          window-rule = {
            match._props = {
              app-id = "^${lib.escapeRegex app}$";
              at-startup = true;
            };
            open-on-workspace = workspace.name;
          };
        }) workspace.apps;
    in
    {
      wayland.windowManager.niri.settings._children =
        map renderWorkspace ordered ++ lib.concatMap renderRules ordered;
    };
}
