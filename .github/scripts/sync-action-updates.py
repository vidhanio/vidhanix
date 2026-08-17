#!/usr/bin/env python3
"""Sync Dependabot's GitHub Actions version bumps into their Nix sources."""

from __future__ import annotations

import os
import re
import subprocess
import sys
from pathlib import Path

WORKFLOWS = ".github/workflows"
ACTIONS = ".github/actions"
SOURCES = Path("modules/flake/files/workflows")

REF = re.compile(r"[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+@v[0-9]+(?:\.[0-9]+){0,2}")


def run(*command: str) -> str:
    """Run a command and return its output."""
    return subprocess.run(command, check=True, text=True, capture_output=True).stdout


def yaml_files(commit: str) -> list[str]:
    """Return the workflow and action yaml files at a commit."""
    return [
        path
        for path in run(
            "git", "ls-tree", "-r", "--name-only", commit, "--", WORKFLOWS, ACTIONS
        ).splitlines()
        if path.endswith((".yaml", ".yml"))
    ]


def uses_refs(commit: str, path: str) -> list[str]:
    """Return the upstream action refs used by a yaml file at a commit."""
    try:
        blob = run("git", "show", f"{commit}:{path}")
    except subprocess.CalledProcessError:
        return []  # file added by the PR; nothing to sync
    return [
        ref
        for ref in re.findall(r"^\s*(?:-\s+)?uses:\s*(\S+)", blob, re.MULTILINE)
        if REF.fullmatch(ref)
    ]


def updates(base: str, head: str) -> dict[str, str]:
    """Map refs the PR bumped from old to new version."""
    found: dict[str, str] = {}
    for path in yaml_files(head):
        old, new = uses_refs(base, path), uses_refs(head, path)
        if len(old) != len(new):
            raise ValueError(f"uses count changed in {path}")
        for before, after in zip(old, new):
            if before != after and before.rsplit("@", 1)[0] == after.rsplit("@", 1)[0]:
                found[before] = after
    if not found:
        raise ValueError("no action updates in the PR")
    return found


def sync_sources(found: dict[str, str]) -> list[Path]:
    """Apply the bumps as a plain find-replace in the Nix sources."""
    changed = []
    for path in sorted(SOURCES.glob("*.nix")):
        text = path.read_text()
        new_text = text
        for old, new in found.items():
            new_text = new_text.replace(old, new)
        if new_text != text:
            path.write_text(new_text)
            changed.append(path)
    return changed


def diff_is_clean(commit: str) -> bool:
    """Whether the worktree matches a commit in the source directory."""
    return (
        subprocess.run(
            ("git", "diff", "--quiet", commit, "--", str(SOURCES)),
            check=False,
        ).returncode
        == 0
    )


def main() -> int:
    try:
        # skip anything that is not a dependabot github_actions PR against main
        if (
            os.environ["BASE_REF"] != "main"
            or os.environ["HEAD_REPO"] != os.environ["GITHUB_REPOSITORY"]
            or not os.environ["HEAD_REF"].startswith("dependabot/github_actions/")
        ):
            return 0
        run(
            "git",
            "fetch",
            "--no-tags",
            "origin",
            f"refs/pull/{os.environ['PR_NUMBER']}/head:refs/remotes/origin/dependabot-head",
        )
        head = os.environ["HEAD_SHA"]
        found = updates(os.environ["BASE_SHA"], head)
        changed = sync_sources(found)
        if not changed or diff_is_clean(head):
            # the PR head already carries this sync; leave the tree untouched
            if changed:
                run("git", "checkout", "--", str(SOURCES))
            print("the PR already contains the source sync")
            return 0
        run("git", "add", *map(str, changed))
    except (ValueError, subprocess.CalledProcessError) as error:
        print(f"dependabot sync failed: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
