# AGENTS.md

This file guides coding agents working in this repository.

## What this is

A [dendritic](https://github.com/mightyiam/dendritic) Nix flake holding the NixOS and Home Manager configuration for two hosts: `vidhan-pc` and `vidhan-macbook` (Apple Silicon, Asahi).

## State

`TODO.md` tracks the current work — in-flight restructures, decisions, and next steps. Read it before starting; update it as the plan changes.

## Work eval-first

The dev shell (loaded by direnv) provides `just`, which runs the recipes in the generated `justfile` and its modules (`eval`, `docs`, `build`, `inspect`). Prefer `just` over raw `nix` commands wherever a recipe exists: the recipes fill in the host name, the user name, and the generated files, and each one documents itself.

Work eval-first: verify every change by evaluation, and keep the rebuild for the end.

1. Edit a module. If you created a file, `just add` (`git add -AN`) first — Nix ignores untracked files.
2. Verify with `just eval` — evaluation is fast and builds nothing.
3. Apply with `just switch`, which regenerates the files, then runs `nh os switch`. `just boot` and `just test` run the other `nh os` actions.

`prek` runs the pre-commit hooks: treefmt, `generate-files`, and a Conventional Commits check. Write each commit message as `type: description`.

## The recipe map

`just` lists every recipe in every justfile; `just --list <module>` shows one module. The modules all take the same shape — `<tree> <option>`, where `<tree>` is `nixos`, `hm`, `flake`, or `perSystem` — filled in for the current machine.

**Understand — `just docs <tree> <option>`.** The best agent context for any option. It renders the option's markdown docs — description, type, default, examples — prose written for reading. Reach for it whenever an option is unfamiliar: `just eval` shows the current value, `just docs` shows the meaning. It works in any tree, including this flake's own options:

```sh
just docs nixos services.printing
just docs hm programs.git
just docs flake perSystem.readme
just docs perSystem files.commentedFile
```

**Check — `just eval <tree> <option> [flags]`.** Evaluate the option's value:

```sh
just eval nixos services.printing
just eval hm programs.git
```

Evaluate the whole program or service, not just the option you changed: `nix eval` forces every option under the attribute, so it catches an error anywhere in the module. Judge the output text, not the exit code — an inline `«error: ...»` marks one broken option, and the command still exits with status 0. Ignore a `trace: Obsolete option ...` line; it comes from a rename in nixpkgs or Home Manager, unless the name is one that this repository sets.

Trailing flags go to `nix eval`:

- `--raw` prints the content of one text option, such as a generated configuration file.
- `--json` stops at the first broken option. Keep it for a narrow leaf, as in `just eval hm programs.git.settings.user --json`.

`just eval system` evaluates the full configuration — it builds nothing and takes about 35 seconds. Run it before a rebuild.

**Look inside — `just inspect <tree> <option> <cmd>`.** Build a path and run a command in its output directory:

```sh
just inspect flake .#muvm-steam ls -la
just inspect nixos system.build.toplevel ls -la
just inspect hm home.path ls -la
```

**Build — `just build <tree> <option>`.** Build a path and print its output store paths without linking `result`. `just build flake <path>` also takes a raw flake path or nix build expression.

## Architecture

### Auto-import

`import-tree` imports each `.nix` file under `modules/` as a flake-parts module. There is no import list. To add a module, add the file. That is sufficient.

### Generated files

`flake.nix` is generated. Never edit it. To add an input, declare it in the module that uses it, then regenerate:

```nix
flake-file.inputs.<name>.url = "github:owner/repo";
```

`README.md` is generated the same way. A module adds a README section with `readme.content.<section>.content`, and a `.gitignore` line with `perSystem.files.gitignore`.

`justfile` and its `*.just` modules are generated the same way. A module declares variables with `justfile.vars.<name>`, recipes with `justfile.recipes.<name>` (in `justfile.order`), and submodules with `justfile.modules.<name>`, each rendered to `<name>.just`.

### Module aggregates

A module contributes to a named aggregate. A module does not target a host directly.

- `flake.modules.nixos.default` and `flake.modules.homeManager.default` apply to each host and each user.
- `flake.modules.nixos.desktop` and `flake.modules.nixos.macbook` are the bases in `modules/systems/bases/`. Each base imports `default`.

A host file in `modules/systems/configurations/<hostname>/` sets `configurations.<hostname>`. Its `module.imports` selects a base.

### Flake-level options

Two option trees live at the flake level, not in NixOS:

- `users.<username>` (`modules/systems/users/default.nix`) — full name, email, SSH public keys, and a Home Manager `module`.
- `configurations.<hostname>` (`modules/systems/configurations/default.nix`) — builds `nixosConfigurations`, creates the user accounts, connects Home Manager, and collects the host SSH keys into `programs.ssh.knownHosts`.

### One file for each program

A program module lives at `modules/programs/<name>.nix` while it fits in one file; the moment it needs a second file it becomes a directory `modules/programs/<name>/`, and the main module is always `default.nix`. Fragments are named by role — `options.nix`, `package.nix`, `stylix.nix`, a `SKILL.md` directly in the directory — or by the feature they hold, like `git/signing.nix`.

A program module sets the Home Manager or NixOS options. It also contributes to the cross-cutting options that other modules declare:

- `persist.directories` and `persist.files` — impermanence, in both NixOS and Home Manager.
- `hyprland.binds."<key>"` and `hyprland.autostartWorkspaces.<name>`.
- `xdg.autostart.entries`.

`modules/programs/comma/default.nix` shows this pattern.

### One services tree

All services live in `modules/services/`; each file declares its own level (NixOS or Home Manager). A user-facing app that needs an activation hook is a program, not a service. Client-side config lives in `modules/programs/`, host-side daemons in `modules/systems/` — as with SSH: `programs/ssh.nix` holds the client's known hosts, `systems/ssh/` holds the daemon.

### Packages

Define a package in `perSystem.packages.<name>`, usually in a `package.nix` file beside the module. `meta.description` is necessary, because the README table reads it. Add `passthru.updateScript` to include the package in `just update-packages`.

## Constraints

- Import from derivation is off (`allow-import-from-derivation = false`). Evaluation fails if a module reads a build output.
- treefmt sets `on-unmatched = "fatal"`. A new file type needs a formatter in `modules/flake/treefmt.nix`. If the formatter is absent, `just fmt` fails.
- `self'` and `inputs'` are ordinary module arguments in NixOS and Home Manager modules. Use them in place of `withSystem`.
- Comment only what the code cannot say — the non-obvious why — one line, plain words.
- Secrets are in `secrets/secrets.yaml` (sops-nix, age keys from SSH keys). Reference a secret with `sops.secrets.<path>`.
