# AGENTS.md

This repo is my NixOS config. It contains system preferences, programs, and program configurations.

# Development Cycle

Run `just --list` to view the commands available to you via the `justfile`.
Prefer `just` commands over raw shell invocations. They automatically stage changed files (`git add -A`) and handle quirks like files that need to be tracked via git for the flake to recognize them, etc.

After making any change, run `just fmt` to keep it compliant with our formatter.

After making any small focused changes, run `just eval-{nixos,hm,...} <option path>` to ensure the change didn't break anything.
I would recommend evaluating the larger concept the option belongs to. For example, instead of evaluating `services.openssh.settings.PasswordAuthentication`, evaluate `services.openssh`.
You may use the `just build-*` variants if testing a derivation/package build.

When you are done with your unit of work, run our final set of commands to ensure that the larger system is still functional.

```sh
just fmt --ci
just generate
just eval-system
just build-system # optional, slow. only run if any packages were changed
```

## Generated Files

Many of the files in this repository are automatically generated and marked with a `# @generated` marker at the top of the file.
Never modify these files by hand. Figure out where the relevant code is in `modules/flake/files/` and edit it, then run `just generate` to update these files.

## Style

Keep commit titles, comments, and CLI errors lowercase.
Keep comments short, and only add them when absolutely needed and the intent of a piece of code isn't obvious.

Use commit titles in the format `<scope>: <description>`, such as `kitty: disable close confirmation`. Commit each finished unit of work promptly, with no unrelated changes. Fold small follow-up changes into the current unit's commit instead of creating a series of tiny commits, and update the title when the unit's scope changes. Leave no uncommitted work after a finished unit.
