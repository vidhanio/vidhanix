{ lib, ... }:
{
  flake.modules.homeManager.default =
    { config, ... }:
    let
      cfg = config.hyprland.autostartWorkspaces;
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
          windowrule = lib.mapAttrsToList (
            class: workspace: "match:class ${class}, workspace ${toString workspace} silent"
          ) cfg;
          exec-once = lib.mapAttrsToList (
            class: _: "sleep 10 && hyprctl keyword windowrule \"match:class ${class}, workspace unset\""
          ) cfg;
        };
      };
    };
}
