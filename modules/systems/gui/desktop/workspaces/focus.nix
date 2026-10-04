{ lib, ... }:
{
  flake.aspects.desktop.homeManager =
    { config, pkgs, ... }:
    let
      niriFocus = pkgs.writeShellApplication {
        name = "toggle-work-workspace";
        runtimeInputs = [
          pkgs.niri
          pkgs.jq
        ];
        text = ''
          if niri msg --json workspaces | jq -e 'any(.[]; .name == "work" and .is_focused)' >/dev/null; then
            niri msg action focus-workspace-previous
          else
            niri msg action focus-workspace work
          fi
        '';
      };
    in
    {
      config = lib.mkIf (config.desktop.workspaces ? work) {
        desktop.binds."SUPER + w" = {
          niri.cmd = lib.getExe niriFocus;
          hyprland.lua = ''
            function()
                        local current = hl.get_active_workspace()
                        hl.dispatch(hl.dsp.focus({
                          workspace = current ~= nil and current.name == "work" and "previous" or "work"
                        }))
                      end'';
        };
      };
    };
}
