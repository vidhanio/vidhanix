# AGENTS.md

This repo is my NixOS system config. It contains system preferences, programs, and program configurations.

## Development

Run `just --list` to view the commands available to you via the `justfile`.
Prefer `just` commands over raw `git`/`nix` commands where possible.

## Style

Add comments only when absolutely needed, and keep them concise.

Use commit titles in the format `<scope>: <description>`, such as `kitty: disable close confirmation`. Commit each finished unit of work promptly, with no unrelated changes. Fold small follow-up changes into the current unit's commit instead of creating a series of tiny commits, and update the title when the unit's scope changes. Leave no uncommitted work after a finished unit.
