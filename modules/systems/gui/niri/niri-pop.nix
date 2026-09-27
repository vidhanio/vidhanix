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

            mkdir -p "$XDG_RUNTIME_DIR/niri-pop"
            state="$XDG_RUNTIME_DIR/niri-pop/$appid.json"
            saved=$(jq -r '.window // empty' "$state" 2>/dev/null || true)

            if [[ -z $saved ]]; then
              saved=null
            fi

            windows=$(niri msg --json windows)
            window=$(jq -r --arg appid "$appid" --argjson saved "$saved" '
              ([.[] | select(.app_id == $appid and .id == $saved)] | first | .id)
              // ([.[] | select(.app_id == $appid)] | first | .id)
              // empty' <<<"$windows")

            if [[ -z $window ]]; then
              rm -f "$state"
              niri msg action spawn -- "$@"
              exit 0
            fi

            if [[ -f $state ]] && [[ $(jq -r --argjson id "$window" 'any(.id == $id and .is_focused)' <<<"$windows") == true ]]; then
              previous=$(jq -r '.previous // empty' "$state")

              if [[ -n $previous ]]; then
                niri msg action focus-window --id "$previous" || true
              fi

              output=$(jq -r '.output' "$state")

              if [[ $output != $(niri msg --json focused-output | jq -r '.name') ]]; then
                niri msg action move-window-to-monitor --id "$window" "$output"
              fi

              index=$(jq -r '.workspace' "$state")
              current=$(niri msg --json workspaces | jq -r --argjson id "$(jq -r '.workspace_id' "$state")" '[.[] | select(.id == $id) | .idx] | first // empty')

              if [[ -n $current ]]; then
                index=$current
              fi

              niri msg action move-window-to-workspace --window-id "$window" "$index" --focus false
              niri msg action move-window-to-tiling --id "$window"
              rm -f "$state"
              exit 0
            fi

            workspaces=$(niri msg --json workspaces)
            read -r index output <<<"$(jq -r '.[] | select(.is_focused) | "\(.idx) \(.output)"' <<<"$workspaces")"

            if [[ ! -f $state ]]; then
              previous=$(niri msg --json focused-window | jq -r --argjson id "$window" 'if .id == $id then empty else (.id // empty) end')

              if [[ -z $previous ]]; then
                previous=null
              fi

              jq -n --argjson window "$window" --argjson previous "$previous" --argjson windows "$windows" --argjson workspaces "$workspaces" '
                ($windows | map(select(.id == $window)) | first) as $win
                | ($workspaces | map(select(.id == $win.workspace_id)) | first) as $home
                | {
                  window: $window,
                  previous: $previous,
                  output: $home.output,
                  workspace: $home.idx,
                  workspace_id: $home.id,
                }' >"$state"
            fi

            niri msg action move-window-to-monitor --id "$window" "$output"
            niri msg action move-window-to-workspace --window-id "$window" "$index"
            niri msg action move-window-to-floating --id "$window"
            niri msg action set-window-width --id "$window" 95%
            niri msg action set-window-height --id "$window" 95%
            niri msg action center-window --id "$window"
            niri msg action focus-window --id "$window"
          '';
        })
      ];
    };
}
