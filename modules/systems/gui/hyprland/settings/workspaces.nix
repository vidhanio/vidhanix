{ lib, ... }:
{
  flake.modules = {
    homeManager.default =
      { pkgs, ... }:
      let
        cycleWorkspace = pkgs.writeShellApplication {
          name = "cycle-workspace";

          runtimeInputs = with pkgs; [
            hyprland
            jq
          ];

          text = ''
            set -eu

            direction="''${1:-}"

            case "$direction" in
              next)
                offset=1
                ;;
              prev)
                offset=-1
                ;;
              *)
                printf 'usage: %s <next|prev>\n' "$0" >&2
                exit 1
                ;;
            esac

            monitors_json="$(hyprctl -j monitors)"
            workspaces_json="$(hyprctl -j workspaces)"
            current_workspace="$(jq -r '.[] | select(.focused) | .activeWorkspace.id' <<< "$monitors_json")"
            # Skip workspaces that are currently visible on other monitors.
            blocked_workspaces="$(jq -c '[.[] | select(.focused | not) | .activeWorkspace.id | select(. > 0)]' <<< "$monitors_json")"
            highest_occupied_workspace="$(jq -r '[.[] | select(.id > 0 and .windows > 0) | .id] | max // 0' <<< "$workspaces_json")"
            # Allow exactly one trailing empty workspace before wrapping.
            cycle_limit=$((highest_occupied_workspace + 1))

            if [ "$cycle_limit" -lt 1 ]; then
              cycle_limit=1
            fi

            if [ "$current_workspace" -gt "$cycle_limit" ]; then
              cycle_limit="$current_workspace"
            fi

            # Build the ordered cycle list once, then index into it.
            mapfile -t candidates < <(
              jq -nr \
                --argjson blocked "$blocked_workspaces" \
                --argjson cycleLimit "$cycle_limit" \
                '[range(1; $cycleLimit + 1) as $workspace | select(($blocked | index($workspace)) | not) | $workspace] | .[]'
            )

            if [ "''${#candidates[@]}" -eq 0 ]; then
              exit 0
            fi

            current_index=-1
            for i in "''${!candidates[@]}"; do
              if [ "''${candidates[$i]}" -eq "$current_workspace" ]; then
                current_index=$i
                break
              fi
            done

            if [ "$current_index" -lt 0 ]; then
              current_index=0
            fi

            target_index=$(((current_index + offset + ''${#candidates[@]}) % ''${#candidates[@]}))
            target_workspace="''${candidates[$target_index]}"

            hyprctl dispatch focusworkspaceoncurrentmonitor "$target_workspace"
          '';
        };

      in
      {
        wayland.windowManager.hyprland.settings = {
          gesture = "3, horizontal, workspace";

          bind =
            let
              workspaceBindings =
                i:
                let
                  istr = toString i;
                in
                [
                  # Switch to workspace i
                  "SUPER, ${istr}, focusworkspaceoncurrentmonitor, ${istr}"
                  # Move focused window to workspace i
                  "SUPER SHIFT, ${istr}, movetoworkspacesilent, ${istr}"
                ];
            in

            lib.concatMap workspaceBindings (lib.range 1 9)
            ++ [
              # Special workspace (scratchpad)
              "SUPER, S, togglespecialworkspace"
              "SUPER SHIFT, S, movetoworkspace, special"

              # Cycle through available workspaces with SUPER + TAB
              "SUPER, Tab, exec, ${lib.getExe cycleWorkspace} next"
              "SUPER SHIFT, Tab, exec, ${lib.getExe cycleWorkspace} prev"
            ];
        };
      };
  };

  configurations.vidhan-pc.homeModule = {
    wayland.windowManager.hyprland.settings.bind = lib.mkAfter [
      "SUPER, grave, swapactiveworkspaces, current +1"
      "SUPER SHIFT, grave, focusmonitor, +1"
    ];
  };
}
