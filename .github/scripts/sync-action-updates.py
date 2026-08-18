#!/usr/bin/env python3
"""Sync Dependabot's GitHub Actions version bumps into their Nix sources."""

from __future__ import annotations

import json
import os
import re
import subprocess
import sys
from pathlib import Path

SOURCES = Path("modules/flake/files/github")

FULL_SHA = re.compile(r"[0-9a-f]{40}")


def run(*command: str) -> str:
    """Run a command and return its output."""
    return subprocess.run(command, check=True, text=True, capture_output=True).stdout


def ref(version: str) -> str:
    """The `uses:` form of an action version: SHAs stay bare, tags get a leading `v`."""
    return version if FULL_SHA.fullmatch(version) else f"v{version}"


def bumps(dependencies: list[dict]) -> dict[str, str]:
    """Map the refs the PR bumps from the old to the new version."""
    found: dict[str, str] = {}
    for dependency in dependencies:
        previous = dependency["prevVersion"]
        latest = dependency["newVersion"]
        if not previous or not latest:
            continue
        name = dependency["dependencyName"]
        old = f"{name}@{ref(previous)}"
        new = f"{name}@{ref(latest)}"
        if old != new:
            found[old] = new
    return found


def main() -> int:
    try:
        bumped = bumps(json.loads(os.environ["UPDATED_DEPENDENCIES_JSON"]))
        if not bumped:
            print("No version bumps in the PR metadata.")
            return 0
        changed = []
        for path in sorted(SOURCES.glob("*.nix")):
            text = path.read_text()
            new_text = text
            for old, new in bumped.items():
                new_text = new_text.replace(old, new)
            if new_text != text:
                path.write_text(new_text)
                changed.append(path)
        if not changed:
            # the bot's previous sync already covers this update
            print("The PR already contains the source sync.")
            return 0
        run("git", "add", *map(str, changed))
    except (KeyError, ValueError, subprocess.CalledProcessError) as error:
        print(f"dependabot sync failed: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
