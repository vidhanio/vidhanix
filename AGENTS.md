# AGENTS.md

This repo is my NixOS config. It contains system preferences, programs, and program configurations.
It uses Dendritic architecture, meaning every nix file in `modules/` is merged without ever needing manual `import`/`imports = []` statements.
[Aspects](https://flake-aspects.denful.dev) may span one or more module classes (`nixos`, `homeManager`, etc.) and are then consumed via hosts, users, other aspects, etc.

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

## Adding Modules

When asked to add a program or service, search before creating anything: look for an existing module under `modules/` (e.g. `modules/programs/<name>/`) and run `just search-nixos <option>` / `just search-hm <option>` to confirm NixOS/home-manager options exist for it.

If no module exists, ask the user whether they just want to configure it directly, or create a new module with their own `options.nix`/`default.nix`.

## Generated Files

Many of the files in this repository are automatically generated and marked with a `# @generated` marker at the top of the file.
Never modify these files by hand. Figure out where the relevant code is in `modules/flake/files/` and edit it, then run `just generate` to update these files.

Flake inputs are declared with `flake-file.inputs.<name>` in the module that uses them.
`just generate` aggregates them into the root `flake.nix`, brings `flake.lock` up to date, and removes duplicate inputs (via nix-auto-follow's `flake-file.prune-lock`).

## Style

Keep commit titles, comments, and CLI errors lowercase.
Keep comments short, and only add them when absolutely needed and the intent of a piece of code isn't obvious.
Never inline a class configuration: use `flake.aspects.<name> = { <class> = { ... }; };` instead of `flake.aspects.<name>.<class> = ...`, even when the class has only one setting.

Use conventional commits. Commit each finished unit of work promptly, with no unrelated changes. Leave no uncommitted work after a finished unit.
