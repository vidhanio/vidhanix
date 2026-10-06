# AGENTS.md

This is my dendritic NixOS flake for system preferences, programs, and configurations across my machines.

## Structure

- Look for an existing aspect under `modules/` and follow nearby patterns.
- Files under `modules/` are imported automatically. Declare configuration under `flake.aspects.<name>` with the appropriate classes (usually `homeManager` or `nixos`); do not add manual imports.
- Prefer upstream Home Manager options for user configuration and NixOS options for system-level features. Packages alone can go in `home.packages`.
- Put feature configuration in `modules/{programs,services,systems}/<name>/default.nix`. When a local module is needed, keep its option declarations and implementation in `options.nix`, and enable/configure it in `default.nix`. Keep the same aspect name across files and classes.
- Add shared aspects to `modules/systems/profiles/core/default.nix` when needed without a graphical session, otherwise to `modules/systems/profiles/gui/default.nix`. Keep sorted blocks sorted.
- Edit the Nix sources of generated files, not their generated output; regenerate with `just generate`.

## Workflow

- Load the dev shell with `direnv reload`.
- Use `just` recipes where helpful
- Stage new files before Nix evaluation so the flake can see them. Some recipes run `git add -A`, so check for unrelated changes first.
- Format with `nix fmt` and validate the affected configuration with an appropriate evaluation or build. Do not activate the system unless asked.
- Add comments only when necessary, and keep them concise.
- Commit each finished unit of work with a lowercase `<scope>: <description>` title, e.g. `kitty: disable close confirmation`.
- Fold small follow-ups into the current unit's commit. Leave no task changes uncommitted, and do not include unrelated changes.
