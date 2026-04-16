{ lib, ... }:
{
  flake.modules.homeManager.default =
    { config, ... }:
    let
      cfg = config.hyprland.autostartWorkspaces;

      workspaceRule = class: workspace: "match:class ${class}, workspace ${toString workspace} silent";
      unsetRule = class: "match:class ${class}, workspace unset";
    in
    {
      options.hyprland.autostartWorkspaces = lib.mkOption {
        type = lib.types.attrsOf lib.types.ints.positive;
        default = { };
        description = ''
          Map Hyprland window classes to temporary startup workspace assignments.
        '';
      };

      config = lib.mkIf (cfg != { }) {
        wayland.windowManager.hyprland.settings = {
          windowrule = lib.mkBefore (lib.mapAttrsToList workspaceRule cfg);
          exec-once = lib.mkAfter (
            lib.mapAttrsToList (class: _: "sleep 5 && hyprctl keyword windowrule \"${unsetRule class}\"") cfg
          );
        };
      };
    };
}
