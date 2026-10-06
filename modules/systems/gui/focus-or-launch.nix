{
  profiles.pc.homeModule = { pkgs, ... }: {
    home.packages = [
      (pkgs.writeShellApplication {
        name = "focus-or-launch";
        runtimeInputs = [
          pkgs.hyprland
          pkgs.jq
          pkgs.niri
          pkgs.uwsm
        ];
        text = ''
          if [[ $# -lt 2 ]]; then
            echo "usage: focus-or-launch <app-id> <command> [args...]" >&2
            exit 2
          fi

          appid=$1
          shift

          if [[ -n "''${NIRI_SOCKET:-}" && -S "$NIRI_SOCKET" && "$NIRI_SOCKET" == "$XDG_RUNTIME_DIR/niri.$WAYLAND_DISPLAY."* ]]; then
            id=$(niri msg --json windows | jq -r --arg appid "$appid" 'map(select(.app_id == $appid)) | first | .id // empty')
            if [[ -n "$id" ]]; then
              niri msg action focus-window --id "$id"
            else
              niri msg action spawn -- "$@"
            fi
          elif [[ "''${XDG_CURRENT_DESKTOP:-}" == *[Hh]yprland* && -n "''${HYPRLAND_INSTANCE_SIGNATURE:-}" && -S "$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket.sock" ]]; then
            address=$(hyprctl -j clients | jq -r --arg appid "$appid" 'map(select(.class == $appid)) | first | .address // empty')
            if [[ -n "$address" ]]; then
              hyprctl eval "hl.dispatch(hl.dsp.focus({ window = \"address:$address\" }))"
            else
              uwsm app -- "$@"
            fi
          else
            echo "focus-or-launch: no compositor IPC for ''${WAYLAND_DISPLAY:-unset}" >&2
            exit 1
          fi
        '';
      })
    ];
  };
}
