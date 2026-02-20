---
name: nixos-build
description: Validate NixOS configuration changes by running nh os build and interpreting errors
compatibility: opencode
---

## What I do

After making changes to any `.nix` files in this repository, run `nh os build` to validate the configuration evaluates and builds without errors.

## How to run

```bash
nh os build
```

Run from the repo root (`/home/vidhanio/Projects/vidhanix`). The build typically takes 10–60 seconds.

## Interpreting output

- **Success**: output ends with `✔ nixos-system-...` and a `SIZE` / `DIFF` summary. No action needed.
- **Evaluation error** (`error: ...`): a Nix expression is invalid. Read the error trace to find the offending file and line, fix it, and re-run.
- **Missing path** (`path '...' does not exist`): a relative path to a secret or file is wrong. Count the directory depth of the referencing `.nix` file relative to the repo root and correct the `../` prefix count so it resolves to `secrets/<name>.age` at the repo root.
- **Type/option error** (`The option ... does not exist` / `is not of type`): a Home Manager or NixOS option is misused. Check the module definition and fix the value or type.

## When to use

Use this skill any time `.nix` files are created or modified — especially when touching:

- `age.secrets.*.file` paths
- New module options or `config` blocks
- Package definitions or `perSystem` expressions
- Any file under `modules/`

Always run before declaring a task complete.
