import fcntl
import json
import math
import os
import signal
import sys
import time
from datetime import datetime
from pathlib import Path
from subprocess import DEVNULL, PIPE, CalledProcessError, Popen, check_output, run

UNIT = "desktop-screen-record.service"
Box = tuple[int, int, int, int]


def query(*command: str):
    return json.loads(check_output(command, text=True))


def geometry(box: Box) -> str:
    x, y, width, height = box
    return f"{x},{y} {width}x{height}"


def targets() -> tuple[str, list[Box], list[Box]]:
    candidates = []
    if "niri" in os.environ.get("XDG_CURRENT_DESKTOP", "").lower():
        compositor = "niri"
        outputs = {
            name: (
                data["logical"]["x"],
                data["logical"]["y"],
                data["logical"]["width"],
                data["logical"]["height"],
            )
            for name, data in query("niri", "msg", "--json", "outputs").items()
            if data["logical"] is not None
        }
        active = {
            w["id"]: w["output"]
            for w in query("niri", "msg", "--json", "workspaces")
            if w["is_active"]
        }
        for window in query("niri", "msg", "--json", "windows"):
            output = outputs.get(active.get(window["workspace_id"]))
            layout = window["layout"]
            position = layout["tile_pos_in_workspace_view"]
            if output is not None and position is not None:
                candidates.append(
                    (
                        output[0] + position[0],
                        output[1] + position[1],
                        *layout["tile_size"],
                        output,
                    )
                )
    else:
        compositor = "hyprland"
        monitors = {m["id"]: m for m in query("hyprctl", "-j", "monitors")}
        outputs = {}
        for identifier, monitor in monitors.items():
            width, height = monitor["width"], monitor["height"]
            if monitor["transform"] % 2:
                width, height = height, width
            outputs[identifier] = (
                monitor["x"],
                monitor["y"],
                round(width / monitor["scale"]),
                round(height / monitor["scale"]),
            )
        for window in query("hyprctl", "-j", "clients"):
            monitor = monitors.get(window["monitor"])
            if monitor is None or not window["mapped"] or window["hidden"]:
                continue
            active = {
                monitor["activeWorkspace"]["id"],
                monitor["specialWorkspace"].get("id"),
            }
            if window["pinned"] or window["workspace"]["id"] in active:
                candidates.append(
                    (*window["at"], *window["size"], outputs[window["monitor"]])
                )
    windows = []
    for x, y, width, height, (ox, oy, ow, oh) in candidates:
        left, top = max(math.floor(x), ox), max(math.floor(y), oy)
        right, bottom = (
            min(math.ceil(x + width), ox + ow),
            min(math.ceil(y + height), oy + oh),
        )
        if right > left and bottom > top:
            windows.append((left, top, right - left, bottom - top))
    return compositor, list(outputs.values()), windows


def freeze_ready(process: Popen, compositor: str, count: int) -> None:
    deadline = time.monotonic() + 3
    while process.poll() is None and time.monotonic() < deadline:
        if compositor == "hyprland":
            layers = [
                layer
                for monitor in query("hyprctl", "-j", "layers").values()
                for level in monitor["levels"].values()
                for layer in level
                if layer["pid"] == process.pid and layer["alpha"] == 1
            ]
        else:
            layers = [
                layer
                for layer in query("niri", "msg", "--json", "layers")
                if layer["namespace"] == "hyprpicker"
            ]
        if len(layers) == count:
            return
        time.sleep(0.02)
    raise SystemExit("Could not freeze the displays.")


def select(windows: list[Box]) -> Box:
    result = run(
        ["slurp", "-o"],
        input="".join(geometry(w) + "\n" for w in windows),
        text=True,
        stdout=PIPE,
        check=True,
    )
    position, size = result.stdout.split()
    x, y = map(int, position.split(","))
    width, height = map(int, size.split("x"))
    return x, y, width, height


def screenshot(compositor: str, outputs: list[Box], windows: list[Box]) -> None:
    freezer = Popen(["hyprpicker", "-r", "-z", "-d", "-q"], stdout=DEVNULL)
    try:
        freeze_ready(freezer, compositor, len(outputs))
        region = select(windows)
        with Popen(["grim", "-g", geometry(region), "-"], stdout=PIPE) as image:
            run(["wl-copy", "--type", "image/png"], stdin=image.stdout, check=True)
            if image.wait() != 0:
                raise SystemExit("Failed to capture the selected region.")
    finally:
        if freezer.poll() is None:
            freezer.terminate()
        freezer.wait()


def record(outputs: list[Box], windows: list[Box]) -> None:
    x, y, width, height = select(windows)
    if not any(
        ox <= x and oy <= y and x + width <= ox + ow and y + height <= oy + oh
        for ox, oy, ow, oh in outputs
    ):
        raise SystemExit("Screen recording must fit within one monitor.")
    directory = Path(os.environ["CAPTURE_DIRECTORY"])
    directory.mkdir(parents=True, exist_ok=True)
    output = str(directory / f"Recording-{datetime.now():%Y-%m-%d_%H-%M-%S-%f}.mp4")
    args = [
        "-w",
        "region",
        "-region",
        f"{width}x{height}+{x}+{y}",
        "-encoder",
        os.environ["GSR_ENCODER"],
        "-o",
        output,
    ]
    environment = [
        f"--setenv=WAYLAND_DISPLAY={os.environ['WAYLAND_DISPLAY']}",
        "--setenv=XDG_SESSION_TYPE=wayland",
    ]
    if "DISPLAY" in os.environ:
        environment.append(f"--setenv=DISPLAY={os.environ['DISPLAY']}")
    run(
        [
            "systemd-run",
            "--user",
            "--collect",
            f"--unit={UNIT}",
            "--property=KillSignal=SIGINT",
            "--property=PartOf=graphical-session.target",
            *environment,
            "--",
            "gpu-screen-recorder",
            *args,
        ],
        check=True,
    )


def main() -> None:
    if len(sys.argv) != 2 or sys.argv[1] not in {"screenshot", "record"}:
        raise SystemExit("Usage: desktop-capture {screenshot|record}")
    action = sys.argv[1]
    if (
        action == "record"
        and run(
            ["systemctl", "--user", "is-active", "--quiet", UNIT], check=False
        ).returncode
        == 0
    ):
        run(["systemctl", "--user", "stop", UNIT], check=True)
        return
    with (Path(os.environ["XDG_RUNTIME_DIR"]) / "desktop-capture.lock").open(
        "w"
    ) as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return
        compositor, outputs, windows = targets()
        if action == "screenshot":
            screenshot(compositor, outputs, windows)
        else:
            record(outputs, windows)


if __name__ == "__main__":

    def interrupted(signum, _frame):
        raise SystemExit(128 + signum)

    signal.signal(signal.SIGINT, interrupted)
    signal.signal(signal.SIGTERM, interrupted)
    try:
        main()
    except CalledProcessError as error:
        sys.exit(error.returncode)
