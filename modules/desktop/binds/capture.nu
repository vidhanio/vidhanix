const unit = "desktop-screen-record.service"

def main [action: string, --locked]: nothing -> nothing {
    if $action not-in [screenshot record] { error make {msg: "Expected screenshot or record."} }
    if $action == record and (^systemctl --user is-active --quiet $unit | complete).exit_code == 0 {
        ^systemctl --user stop $unit
        return
    }
    if not $locked {
        exec flock --nonblock --close --conflict-exit-code 0 ($env.XDG_RUNTIME_DIR | path join desktop-capture.lock) setpriv --pdeathsig KILL $nu.current-exe --no-config-file $env.CURRENT_FILE $action --locked
    }
    let data = targets
    exit (if $action == screenshot { screenshot $data } else { record $data })
}

def --wrapped query [command: string, ...args: string]: nothing -> any {
    let result = ^$command ...$args | complete
    if $result.exit_code != 0 { error make {msg: $result.stderr} }
    $result.stdout | from json
}

def geometry [box: record]: nothing -> string {
    $"($box.x),($box.y) ($box.width)x($box.height)"
}

def clip [box: record]: nothing -> any {
    let x = [$box.x $box.output.x] | math max | math floor | into int
    let y = [$box.y $box.output.y] | math max | math floor | into int
    let right = [
        ($box.x + $box.width)
        ($box.output.x + $box.output.width)
    ] | math min | math ceil | into int
    let bottom = [
        ($box.y + $box.height)
        ($box.output.y + $box.output.height)
    ] | math min | math ceil | into int
    if $right > $x and $bottom > $y {
        {
            x: $x
            y: $y
            width: ($right - $x)
            height: ($bottom - $y)
        }
    }
}

def targets []: nothing -> record {
    let data = if (($env.XDG_CURRENT_DESKTOP? | default "" | str lowercase) | str contains niri) {
        let outputs = query niri msg --json outputs | transpose name data | where data.logical != null | each {|output|
      $output.data.logical | insert name $output.name
    }
        let workspaces = query niri msg --json workspaces | where is_active
        let windows = query niri msg --json windows | each {|window|
      let workspace = $workspaces | where id == $window.workspace_id | get --optional 0
      let position = $window.layout.tile_pos_in_workspace_view
      if $workspace != null and $position != null {
        let output = $outputs | where name == $workspace.output | get --optional 0
        if $output != null {
          {x: ($output.x + $position.0) y: ($output.y + $position.1) width: $window.layout.tile_size.0 height: $window.layout.tile_size.1 output: $output}
        }
      }
    }
        {compositor: niri, outputs: $outputs, windows: $windows}
    } else {
        let outputs = query hyprctl -j monitors | each {|monitor|
      let size = if $monitor.transform mod 2 == 1 { [$monitor.height $monitor.width] } else { [$monitor.width $monitor.height] }
      $monitor | update width (($size.0 / $monitor.scale) | math round | into int) | update height (($size.1 / $monitor.scale) | math round | into int)
    }
        let windows = query hyprctl -j clients | where {|window| $window.mapped and not $window.hidden } | each {|window|
      let output = $outputs | where id == $window.monitor | get --optional 0
      if $output != null {
        let active = [$output.activeWorkspace.id ($output | get --optional specialWorkspace.id)]
        if $window.pinned or $window.workspace.id in $active {
          {x: $window.at.0 y: $window.at.1 width: $window.size.0 height: $window.size.1 output: $output}
        }
      }
    }
        {compositor: hyprland, outputs: $outputs, windows: $windows}
    }
    $data | update windows {|data| $data.windows | each {|box| clip $box } }
}

def pick [windows: list<record>]: nothing -> record {
    $windows | each {|box| geometry $box } | str join (char nl) | ^setpriv --pdeathsig KILL slurp -o | complete
}

def freeze []: nothing -> record {
    for dir in (glob ($env.XDG_RUNTIME_DIR | path join ".desktop-capture.*")) {
        rm --recursive --force $dir
    }
    let runtime = (
        mktemp --directory --tmpdir-path $env.XDG_RUNTIME_DIR ".desktop-capture.XXXXXX"
    )
    let display = $env.WAYLAND_DISPLAY? | default "wayland-0"
    let socket = if ($display | str starts-with "/") {
        $display
    } else {
        $env.XDG_RUNTIME_DIR | path join $display
    }
    ^ln -s $socket ($runtime | path join ($socket | path basename))
    let id = job spawn {
        with-env { XDG_RUNTIME_DIR: $runtime, WAYLAND_DISPLAY: ($socket | path basename) } {
            ^setpriv --pdeathsig KILL hyprpicker -r -z -d -q out> /dev/null
        }
    }
    {id: $id, runtime: $runtime}
}

def unfreeze [frozen: record]: nothing -> nothing {
    if $frozen.id in (job list | get id) { job kill $frozen.id }
    rm --recursive --force $frozen.runtime
}

def wait-freeze [freezer: int, data: record]: nothing -> any {
    let deadline = (date now) + 3sec
    while (date now) < $deadline {
        let running = job list | where id == $freezer
        if ($running | is-empty) { error make {msg: "Screen freeze exited before becoming ready."} }
        let pids = $running | get pids | flatten
        let layers = if $data.compositor == hyprland {
            query hyprctl -j layers | values | get levels | each { values | flatten } | flatten | where {|layer| $layer.pid in $pids and $layer.alpha == 1 }
        } else {
            query niri msg --json layers | where namespace == hyprpicker
        }
        if ($layers | length) == ($data.outputs | length) { return }
        sleep 20ms
    }
    error make {msg: "Could not freeze the displays."}
}

def screenshot [data: record]: nothing -> int {

    # The private runtime keeps hyprpicker's freeze buffers out of the session tmpfs;
    # a SIGKILL would otherwise leak them until the session runs out of space.
    let frozen = freeze
    try {
        wait-freeze $frozen.id $data
        let selected = pick $data.windows
        if $selected.exit_code != 0 {
            print --stderr ($selected.stderr | str trim)
            return $selected.exit_code
        }
        do --capture-errors { ^grim -g ($selected.stdout | str trim) - } | ^wl-copy --type image/png
        $env.LAST_EXIT_CODE
    } finally {
        unfreeze $frozen
    }
}

def record [data: record]: nothing -> int {
    let selected = pick $data.windows
    if $selected.exit_code != 0 {
        print --stderr ($selected.stderr | str trim)
        return $selected.exit_code
    }
    let region = $selected.stdout | str trim | parse "{x},{y} {width}x{height}" | into int x y width height | first
    if not ($data.outputs | any {|output|
    $output.x <= $region.x and $output.y <= $region.y and $region.x + $region.width <= $output.x + $output.width and $region.y + $region.height <= $output.y + $output.height
  }) { error make {msg: "Screen recording must fit within one monitor."} }
    mkdir $env.CAPTURE_DIRECTORY
    let output = $env.CAPTURE_DIRECTORY | path join $"Recording-(date now | format date '%Y-%m-%d_%H-%M-%S-%f').mp4"
    let environment = if $env.DISPLAY? == null { [] } else { [$"--setenv=DISPLAY=($env.DISPLAY)"] }
    ^systemd-run --user --collect $"--unit=($unit)" --property=KillSignal=SIGINT --property=PartOf=graphical-session.target $"--setenv=WAYLAND_DISPLAY=($env.WAYLAND_DISPLAY)" --setenv=XDG_SESSION_TYPE=wayland ...$environment -- gpu-screen-recorder -w region -region $"($region.width)x($region.height)+($region.x)+($region.y)" -encoder $env.GSR_ENCODER -o $output
    $env.LAST_EXIT_CODE
}
