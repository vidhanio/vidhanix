import argparse
import json
from pathlib import Path


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("directory", type=Path)
    parser.add_argument("replacements", type=json.loads)
    args = parser.parse_args()

    for svg in args.directory.rglob("*.svg"):
        content = svg.read_text()
        for source, replacement in args.replacements.items():
            content = content.replace(source, replacement)
        svg.write_text(content)


if __name__ == "__main__":
    main()
