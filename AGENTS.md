# AGENTS.md

This file gives guidance to coding agents that work in this repository.

## What this is

A [dendritic](https://github.com/mightyiam/dendritic) Nix flake. It holds the NixOS and Home Manager configuration for two hosts: `vidhan-pc` and `vidhan-macbook` (Apple Silicon, Asahi).

## Commands

direnv loads the dev shell automatically. The dev shell provides `just`, which runs the recipes in @justfile and its `*.just` modules (`eval`, `build`, `inspect`, `docs`).

Run `just` first — its default recipe lists every recipe in every justfile — and `just --list <module>` to inspect one module. Prefer `just` recipes over raw `nix` commands wherever a recipe exists — the recipes fill in the host name, the user name, and the generated files, and each one documents itself.

- `just switch` — regenerate the files, then run `nh os switch`. This is the normal way to apply a change. `just boot` and `just test` run the other `nh os` actions.
- `just add` — run `git add -AN`. Each recipe that reads the flake depends on this one, because Nix ignores an untracked file.

`prek` runs the pre-commit hooks. The hooks run treefmt, `generate-files`, and a Conventional Commits check. Write each commit message as `type: description`.

## Test a change

To check an edit, evaluate the whole program or service, not the single option that you changed. `nix eval` forces each option under the attribute, so it catches an error anywhere in the module. Evaluation is fast, and it builds nothing. Keep the rebuild for the end of the work.

The `eval` module takes an option path. Each recipe fills in the host name, and `eval hm` also fills in the user name:

```sh
just eval nixos services.printing
just eval hm programs.git
```

Read the output text to judge the result:

- An inline `«error: ...»` marks one broken option. `nix eval` prints it, continues, and exits with status 0. The exit code alone is not sufficient.
- A `trace: Obsolete option ...` line comes from a rename in nixpkgs or Home Manager. Ignore it, unless the name is one that this repository sets.

An argument after the option path goes to `nix eval`:

- `--raw` prints the content of one text option, such as a generated configuration file.
- `--json` stops at the first broken option. Keep it for a narrow leaf, as in `just eval hm programs.git.settings.user --json`.

To read an option's documentation instead of its value, use the `docs` module — it renders the markdown docs for an option in any tree:

```sh
just docs nixos services.printing
just docs hm programs.git
just docs flake perSystem.readme
just docs perSystem files.commentedFile
```

To build a path and look inside its output instead of evaluating it, use the `inspect` module. The trailing arguments are a command run in the output directory:

```sh
just inspect flake .#muvm-steam ls -la
just inspect nixos system.build.toplevel ls -la
just inspect hm home.path ls -la
```

`just build flake <path>` builds a flake path (or a nix build expression) and prints the output store paths.

Run `just eval system` before a rebuild. It evaluates the full configuration, it builds nothing, and it takes about 35 seconds.

## Architecture

### Auto-import

`import-tree` imports each `.nix` file under `modules/` as a flake-parts module. There is no import list. To add a module, add the file. That is sufficient.

### Generated files

`flake.nix` is generated. Never edit it. To add an input, declare it in the module that uses it, then regenerate:

```nix
flake-file.inputs.<name>.url = "github:owner/repo";
```

`README.md` is generated the same way. A module adds a README section with `readme.content.<section>.content`. A module adds a `.gitignore` line with `perSystem.files.gitignore`.

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

A program module holds all of the configuration for that program in one file. It sets the Home Manager or NixOS options. It also contributes to the cross-cutting options that other modules declare:

- `persist.directories` and `persist.files` — impermanence, in both NixOS and Home Manager.
- `hyprland.binds."<key>"` and `hyprland.autostartWorkspaces.<name>`.
- `xdg.autostart.entries`.

`modules/programs/comma/default.nix` shows this pattern.

### Packages

Define a package in `perSystem.packages.<name>`, usually in a `package.nix` file beside the module. `meta.description` is necessary, because the README table reads it. Add `passthru.updateScript` to include the package in `update-packages`.

## Constraints

- Import from derivation is off (`allow-import-from-derivation = false`). Evaluation fails if a module reads a build output.
- treefmt sets `on-unmatched = "fatal"`. A new file type needs a formatter in `modules/flake/treefmt.nix`. If the formatter is absent, `just fmt` fails.
- `self'` and `inputs'` are ordinary module arguments in NixOS and Home Manager modules. Use them in place of `withSystem`.
- Secrets are in `secrets/secrets.yaml` (sops-nix, age keys from SSH keys). Reference a secret with `sops.secrets.<path>`.
