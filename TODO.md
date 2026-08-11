# TODO

State of the current work. Read before starting; update when the plan changes.

## Architecture restructure — in progress

Candidates from the architecture review, all applied except the `ai/` deepen. Applied ones are committed.

- [x] 2. Codify the program-module shape — one file until a second file is needed, then a directory with `default.nix`; rule stated in AGENTS.md
- [x] 3. Collapse the one-option modules — `systems/nix/nix-daemon.nix` and `flake/settings.nix` absorb nine single-line files
- [x] 4. One services tree — everything in `modules/services/`; wakatime moved to `programs/`, systemd persist config to `services/`
- [x] 5. hyprland `options.nix` — binds and autostartWorkspaces interfaces declared in one file
- [x] 6. `mini/` — kept separate as-is; the collapse was considered and rejected (only ~10 of the files are one-liners; pick.nix alone is 375 lines, and the filenames mirror upstream mini.nvim)
- [ ] 1. Deepen `ai/` — one file per harness, herdr inside `harnesses/`, the repeated stylix theme maps and herdr integration behind one interface each

## Next

- Decide whether to apply candidate 1 (the `ai/` deepen) — the subtree churns on every change
- The `modules/programs/ai` harnesses still mix shared infrastructure (`mcp.nix`, `skills/`) with harnesses (`herdr/` outside `harnesses/`)
