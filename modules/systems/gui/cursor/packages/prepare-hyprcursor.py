import argparse
import re
import shutil
from pathlib import Path

DEFINE_SIZE = re.compile(r"define_size\s*=\s*(\d+)\s*,\s*[^,]+\s*,\s*(\d+)")


def svg_sources(svg_directory: Path, cursor_name: str) -> list[Path]:
    animated_directory = svg_directory / cursor_name
    if animated_directory.is_dir():
        return sorted(animated_directory.glob("*.svg"))
    return [svg_directory / f"{cursor_name}.svg"]


def rewrite_metadata(metadata: Path, svgs: list[Path]) -> None:
    output = []
    used = 0

    for line in metadata.read_text().splitlines(keepends=True):
        match = DEFINE_SIZE.fullmatch(line.rstrip("\n"))
        if match is None:
            output.append(line)
        elif int(match.group(1)) == 16:
            if used == len(svgs):
                raise ValueError(f"{metadata}: more frames than SVGs")
            output.append(f"define_size = 0, {svgs[used].name}, {match.group(2)}\n")
            used += 1

    if used != len(svgs):
        raise ValueError(f"{metadata}: found {used} frames for {len(svgs)} SVGs")

    metadata.write_text("".join(output))


def prepare_cursor(
    cursor_directory: Path,
    svg_directory: Path,
    base_color: str,
    outline_color: str,
) -> None:
    for png in cursor_directory.glob("*.png"):
        png.unlink()

    svgs = svg_sources(svg_directory, cursor_directory.name)
    for source in svgs:
        destination = cursor_directory / source.name
        shutil.copy2(source, destination)
        destination.write_text(
            destination.read_text()
            .replace("#00FF00", base_color)
            .replace("#0000FF", outline_color)
        )

    rewrite_metadata(cursor_directory / "meta.hl", svgs)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("theme", type=Path)
    parser.add_argument("svg_directory", type=Path)
    parser.add_argument("base_color")
    parser.add_argument("outline_color")
    args = parser.parse_args()

    for cursor_directory in sorted((args.theme / "hyprcursors").iterdir()):
        prepare_cursor(
            cursor_directory,
            args.svg_directory,
            args.base_color,
            args.outline_color,
        )


if __name__ == "__main__":
    main()
