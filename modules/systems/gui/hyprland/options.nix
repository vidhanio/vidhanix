{ lib, ... }:
{
  flake.aspects.hyprland = {
    homeManager =
      { config, ... }:
      let
        autostartWorkspaces = config.wayland.windowManager.hyprland.autostartWorkspaces;
      in
      {
        options = {
          wayland.windowManager.hyprland = {
            autostartWorkspaces = lib.mkOption {
              type = lib.types.attrsOf lib.types.ints.positive;
              default = { };
              description = ''
                Map Hyprland window classes to temporary startup workspace assignments.
              '';
            };
          };
        };

        config = {
          wayland.windowManager.hyprland = {
            extraConfig = lib.mkIf (autostartWorkspaces != { }) ''
              local autostartWorkspaceRules = {}

              ${lib.concatStringsSep "\n" (
                lib.mapAttrsToList (class: workspace: ''
                  autostartWorkspaceRules[#autostartWorkspaceRules + 1] = hl.window_rule({
                    match = { class = "${class}" },
                    workspace = "${toString workspace} silent",
                  })
                '') autostartWorkspaces
              )}
              -- Only redirect each app's startup launch; let later manual launches behave normally.
              hl.timer(function()
                for _, rule in ipairs(autostartWorkspaceRules) do
                  rule:set_enabled(false)
                end
              end, { timeout = 10000, type = "oneshot" })
            '';
          };
        };
      };
  };
}
