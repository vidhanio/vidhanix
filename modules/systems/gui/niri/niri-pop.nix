{
  flake.aspects.niri.homeManager =
    { pkgs, ... }:
    {
      home.packages = [
        (pkgs.writeShellApplication {
          name = "niri-pop";
          runtimeInputs = [
            pkgs.jq
            pkgs.niri
          ];
          text = ''
            if [[ $# -lt 2 ]]; then
              echo "usage: niri-pop <app-id> <command> [args...]" >&2
              exit 2
            fi

            appid=$1
            shift

            dir="$XDG_RUNTIME_DIR/niri-pop"
            state="$dir/$appid.json"

            windows=$(niri msg --json windows)
            workspaces=$(niri msg --json workspaces)
            focused=$(jq -c '[.[] | select(.is_focused)] | first // {}' <<<"$windows")
            target=$(jq -c --arg appid "$appid" '[.[] | select(.app_id == $appid)] | first // {}' <<<"$windows")
            focused_id=$(jq -r '.id // empty' <<<"$focused")
            target_id=$(jq -r '.id // empty' <<<"$target")
            output=

            if [[ -n $focused_id ]]; then
              output=$(jq -r --argjson id "$(jq -r '.workspace_id' <<<"$focused")" '[.[] | select(.id == $id) | .output] | first // empty' <<<"$workspaces")
            fi

            if [[ $(jq -r '.app_id // empty' <<<"$focused") == "$appid" ]]; then
              home=$(jq -r '.output // empty' "$state" 2>/dev/null || true)
              stored=$(jq -r '.window // empty' "$state" 2>/dev/null || true)
              previous=$(jq -r '.previous // empty' "$state" 2>/dev/null || true)

              if [[ -n $home ]] && [[ $home != "$output" ]] && [[ $stored == "$focused_id" ]]; then
                niri msg action move-workspace-to-monitor "$home" || true
              fi

              if [[ -n $previous ]]; then
                niri msg action focus-window --id "$previous" || true
              fi

              rm -f "$state"
              exit 0
            fi

            mkdir -p "$dir"

            if [[ -z $focused_id ]]; then
              focused_id=null
            fi

            if [[ -z $target_id ]]; then
              target_id=null
            fi

            target_output=

            if [[ $target_id != null ]]; then
              target_output=$(jq -r --argjson id "$(jq -r '.workspace_id' <<<"$target")" '[.[] | select(.id == $id) | .output] | first // empty' <<<"$workspaces")
            fi

            stored=$(jq -r '.window // empty' "$state" 2>/dev/null || true)

            if [[ $target_id != null ]] && [[ $stored == "$target_id" ]]; then
              jq --argjson previous "$focused_id" '.previous = $previous' "$state" >"$state.tmp"
              mv "$state.tmp" "$state"
            else
              jq -n --argjson target "$target" --argjson previous "$focused_id" --argjson workspaces "$workspaces" '
                ($workspaces | map(select(.id == $target.workspace_id)) | first) as $ws
                | {
                  window: ($target.id // null),
                  previous: $previous,
                  output: ($ws.output // null),
                }' >"$state"
            fi

            if [[ $target_id == null ]]; then
              niri msg action spawn -- "$@"
              exit 0
            fi

            niri msg action focus-window --id "$target_id"

            if [[ -n $target_output ]] && [[ -n $output ]] && [[ $target_output != "$output" ]]; then
              niri msg action move-workspace-to-monitor "$output"
            fi
          '';
        })
      ];
    };
}
