{ lib, ... }:
{
  den.default.homeManager =
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
        wayland.windowManager.hyprland.extraConfig = ''
          local autostartWorkspaceRules = {}

          ${lib.concatStringsSep "\n" (
            lib.mapAttrsToList (class: workspace: ''
              autostartWorkspaceRules[#autostartWorkspaceRules + 1] = hl.window_rule({
                match = { class = "${class}" },
                workspace = "${toString workspace} silent",
              })
            '') cfg
          )}
          -- Only redirect each app's startup launch; let later manual launches behave normally.
          hl.timer(function()
            for _, rule in ipairs(autostartWorkspaceRules) do
              rule:set_enabled(false)
            end
          end, { timeout = 15000, type = "oneshot" })
        '';
      };
    };
}
