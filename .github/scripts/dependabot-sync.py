#!/usr/bin/env python3
"""Sync Dependabot's GitHub Actions updates into their Nix sources."""

from __future__ import annotations

import os
import re
import subprocess
import sys
from pathlib import Path

WORKFLOW_ROOT = ".github/workflows"
ACTION_ROOT = ".github/actions"
SOURCE_ROOT = "modules/flake/files/workflows"
VERSION = re.compile(r"v[0-9]+(?:\.[0-9]+){0,2}")
ACTION = re.compile(r"[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+")
YAML_USE = re.compile(r"^[+-](?P<indent>\s*)(?:-\s+)?uses:\s*(?P<ref>\S+)\s*$")
NIX_USE = re.compile(r'^[+-](?P<indent>\s*)uses\s*=\s*"(?P<ref>\S+)";\s*$')


def run(*command: str, capture: bool = False) -> subprocess.CompletedProcess[str]:
    """Run a command and optionally return its output."""
    return subprocess.run(
        command,
        check=True,
        text=True,
        capture_output=capture,
    )


def output(*command: str) -> str:
    """Run a command and return its standard output."""
    return run(*command, capture=True).stdout


def changed_files(base: str, head: str) -> list[tuple[str, str]]:
    """Return changed status/path pairs between two commits."""
    return [
        tuple(line.split("\t", 1))
        for line in output(
            "git", "diff", "--name-status", base, head, "--"
        ).splitlines()
    ]


def parse_patch(patch: str, pattern: re.Pattern[str]) -> list[tuple[str, str]]:
    """Extract paired old/new uses references from a zero-context patch."""
    removed: list[tuple[str, str]] = []
    added: list[tuple[str, str]] = []

    for line in patch.splitlines():
        if line.startswith(("diff ", "index ", "--- ", "+++ ", "@@ ", "\\")):
            continue
        if not line.startswith(("-", "+")):
            continue

        match = pattern.match(line)
        if match is None:
            raise ValueError(f"unexpected changed line in workflow patch: {line}")

        change = removed if line.startswith("-") else added
        change.append((match.group("indent"), match.group("ref")))

    if len(removed) != len(added):
        raise ValueError("workflow patch does not contain paired uses changes")

    pairs = []
    for (old_indent, old), (new_indent, new) in zip(removed, added, strict=True):
        if old_indent != new_indent:
            raise ValueError("workflow uses indentation changed unexpectedly")
        pairs.append((old, new))
    return pairs


def action_ref(ref: str) -> tuple[str, str]:
    """Validate an action reference and return its repository and tag."""
    try:
        repository, version = ref.rsplit("@", 1)
    except ValueError as error:
        raise ValueError(f"invalid action reference: {ref}") from error

    if ACTION.fullmatch(repository) is None or VERSION.fullmatch(version) is None:
        raise ValueError(f"unsupported action reference: {ref}")
    return repository, version


def action_updates(pairs: list[tuple[str, str]]) -> dict[str, str]:
    """Validate and deduplicate generated workflow action updates."""
    updates = {}
    for old, new in pairs:
        old_repository, _ = action_ref(old)
        new_repository, _ = action_ref(new)
        if old_repository != new_repository:
            raise ValueError(f"action repository changed from {old} to {new}")
        if old in updates and updates[old] != new:
            raise ValueError(f"inconsistent update for {old}")
        updates[old] = new
    if not updates:
        raise ValueError("Dependabot PR contains no GitHub Actions updates")
    return updates


def verify_action_tag(ref: str, verified: set[str]) -> None:
    """Verify that an action tag exists on its original repository."""
    if ref in verified:
        return
    repository, version = action_ref(ref)
    run("gh", "api", f"repos/{repository}/git/ref/tags/{version}")
    verified.add(ref)


def validate_source_updates(
    pairs: list[tuple[str, str]],
    repositories: set[str],
    verified: set[str],
) -> None:
    """Allow only the same, existing actions in the source-side diff."""
    for old, new in pairs:
        old_repository, _ = action_ref(old)
        new_repository, _ = action_ref(new)
        if old_repository != new_repository or old_repository not in repositories:
            raise ValueError(f"unexpected source action update from {old} to {new}")
        verify_action_tag(new, verified)


def replace_sources(updates: dict[str, str]) -> list[str]:
    """Apply generated workflow updates to the Nix source files."""
    changed = []
    found = dict.fromkeys(updates, False)
    source_files = sorted(Path(SOURCE_ROOT).glob("*.nix"))

    for path in source_files:
        original = path.read_text()
        text = original
        for old, new in updates.items():
            needle = f'uses = "{old}";'
            if needle in original:
                found[old] = True
            text = text.replace(needle, f'uses = "{new}";')

        if text == original:
            continue
        path.write_text(text)
        changed.append(str(path))

    missing = [old for old, present in found.items() if not present]
    if missing:
        raise ValueError(
            f"could not find action references in Nix sources: {', '.join(missing)}"
        )
    return changed


def diff_exists(commit: str, *paths: str) -> bool:
    """Return whether the worktree differs from a commit at any path."""
    return (
        subprocess.run(
            ("git", "diff", "--quiet", commit, "--", *paths),
            check=False,
        ).returncode
        != 0
    )


def require_environment() -> dict[str, str]:
    """Read and validate values supplied by the trusted workflow."""
    values = {
        name: os.environ.get(name, "")
        for name in (
            "BASE_SHA",
            "HEAD_SHA",
            "HEAD_REF",
            "HEAD_REPO",
            "BASE_REF",
            "PR_NUMBER",
            "PACKAGE_UPDATE_TOKEN",
        )
    }
    if any(not value for value in values.values()):
        raise ValueError("the Dependabot sync environment is incomplete")
    if re.fullmatch(r"[0-9a-f]{40}", values["BASE_SHA"]) is None:
        raise ValueError("invalid base commit")
    if re.fullmatch(r"[0-9a-f]{40}", values["HEAD_SHA"]) is None:
        raise ValueError("invalid head commit")
    if re.fullmatch(r"[0-9]+", values["PR_NUMBER"]) is None:
        raise ValueError("invalid pull request number")
    if not values["HEAD_REF"].startswith("dependabot/github_actions/"):
        raise ValueError("the pull request is not a Dependabot GitHub Actions branch")
    if values["BASE_REF"] != "main":
        raise ValueError("the pull request does not target main")
    if values["HEAD_REPO"] != os.environ.get("GITHUB_REPOSITORY"):
        raise ValueError("the Dependabot branch is not in this repository")
    run("git", "check-ref-format", "--branch", values["HEAD_REF"])
    return values


def main() -> int:
    """Validate a Dependabot workflow diff, regenerate it, and push its source."""
    try:
        values = require_environment()
        os.environ["GH_TOKEN"] = values["PACKAGE_UPDATE_TOKEN"]
        run("gh", "auth", "setup-git")

        run(
            "git",
            "fetch",
            "--no-tags",
            "origin",
            f"refs/pull/{values['PR_NUMBER']}/head:refs/remotes/origin/dependabot-head",
        )
        fetched_head = output(
            "git", "rev-parse", "refs/remotes/origin/dependabot-head"
        ).strip()
        if fetched_head != values["HEAD_SHA"]:
            raise ValueError("the pull request head changed while it was being fetched")
        if output("git", "rev-parse", "HEAD").strip() != values["BASE_SHA"]:
            raise ValueError("the workflow is not running from the pull request base")

        statuses = changed_files(values["BASE_SHA"], values["HEAD_SHA"])
        if not statuses:
            raise ValueError("Dependabot PR has no changed files")
        for status, path in statuses:
            if status != "M":
                raise ValueError(
                    f"Dependabot PR changes {status} {path}; only edits are allowed"
                )
            if not (
                (
                    path.startswith((f"{WORKFLOW_ROOT}/", f"{ACTION_ROOT}/"))
                    and path.endswith(".yaml")
                )
                or (path.startswith(f"{SOURCE_ROOT}/") and path.endswith(".nix"))
            ):
                raise ValueError(f"unexpected file in Dependabot PR: {path}")

        action_patch = output(
            "git",
            "diff",
            "--unified=0",
            values["BASE_SHA"],
            values["HEAD_SHA"],
            "--",
            WORKFLOW_ROOT,
            ACTION_ROOT,
        )
        updates = action_updates(parse_patch(action_patch, YAML_USE))
        verified_tags: set[str] = set()
        for new in updates.values():
            verify_action_tag(new, verified_tags)

        source_paths = [
            path
            for status, path in statuses
            if path.startswith(f"{SOURCE_ROOT}/") and status == "M"
        ]
        if source_paths:
            source_patch = output(
                "git",
                "diff",
                "--unified=0",
                values["BASE_SHA"],
                values["HEAD_SHA"],
                "--",
                SOURCE_ROOT,
            )
            validate_source_updates(
                parse_patch(source_patch, NIX_USE),
                {repository for repository, _ in map(action_ref, updates.values())},
                verified_tags,
            )

        run("git", "checkout", "--detach", values["HEAD_SHA"])
        run("git", "checkout", values["BASE_SHA"], "--", SOURCE_ROOT)
        changed_sources = replace_sources(updates)
        run("nix", "develop", "-c", "just", "generate")

        if diff_exists(values["HEAD_SHA"], WORKFLOW_ROOT, ACTION_ROOT):
            raise ValueError("regenerated actions do not match the Dependabot PR")

        if not diff_exists(values["HEAD_SHA"], SOURCE_ROOT):
            print("Dependabot PR already contains the source sync")
            return 0

        run("git", "add", *changed_sources, WORKFLOW_ROOT)
        run("git", "diff", "--cached", "--check")
        staged = output("git", "diff", "--cached", "--name-only").splitlines()
        if any(
            not path.startswith(
                (f"{WORKFLOW_ROOT}/", f"{ACTION_ROOT}/", f"{SOURCE_ROOT}/")
            )
            for path in staged
        ):
            raise ValueError("generated an unexpected staged file")
        run("git", "commit", "-m", "chore(deps): sync github actions update")
        run(
            "git",
            "push",
            f"--force-with-lease=refs/heads/{values['HEAD_REF']}:{values['HEAD_SHA']}",
            "origin",
            f"HEAD:refs/heads/{values['HEAD_REF']}",
        )
        return 0
    except (ValueError, subprocess.CalledProcessError) as error:
        print(f"dependabot sync failed: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
