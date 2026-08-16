# Repository Guidelines

This file guides coding agents working in this repository.

## Project Overview

A [dendritic](https://github.com/mightyiam/dendritic) Nix flake holding the NixOS and Home Manager configuration for two hosts: `vidhan-pc` (x86_64-linux desktop) and `vidhan-macbook` (aarch64-linux, Apple Silicon via Asahi).

Every `.nix` file under `modules/` is auto-imported as a flake-parts module — there is no import list. Project files (`flake.nix`, `flake.lock`, `README.md`, `justfile` and its `*.just` modules, `.gitignore`, `.envrc`, `LICENSE`) are generated from module-declared options; secrets live in one sops-encrypted file.

## Architecture & Data Flow

**Auto-import.** `flake.nix` is `inputs.flake-parts.lib.mkFlake { ... } (inputs.import-tree ./modules)`. Adding a `.nix` file under `modules/` adds a module. Nix ignores untracked files, so new files need `git add -AN` (the `just add` recipe; the main `just` recipes depend on it).

**Modules never target a host directly** — they contribute to named aggregates:

- `flake.modules.nixos.default` (NixOS), `flake.modules.homeManager.default` (Home Manager) — the common layers. Bases in `modules/systems/bases/` (`desktop`, `macbook`) build `flake.modules.nixos.desktop`/`.macbook` on top of `default` (`macbook` adds `nixos-apple-silicon` with `hardware.asahi.enable`).
- `configurations.<hostname>` — declared in `modules/systems/configurations/default.nix`; builds `flake.nixosConfigurations` via `nixosSystem`, creates the user accounts, connects Home Manager, and collects host SSH keys into `programs.ssh.knownHosts`. A host file (`modules/systems/configurations/<hostname>/default.nix`) sets its entry with `module.imports = [ desktop ]` (or `macbook`).
- `users.<username>` — `modules/systems/users/default.nix`; full name, email, SSH keys, and a Home Manager `module`.

**Cross-cutting options** a module contributes to (rather than setting directly):

- `persist.directories` / `persist.files` — impermanence, in both NixOS and Home Manager.
- `hyprland.binds."<key>"`, `hyprland.autostartWorkspaces.<class>` — declared in `modules/systems/gui/hyprland/options.nix`.
- `xdg.autostart.entries`.
- `flake-file.inputs.<name>.url` — declares a flake input (serialized into `flake.nix`).
- `perSystem.files.gitignore`, `files.readme.content.<section>.content`, `files.justfile.recipes` / `files.justfile.vars` / `files.justfile.modules`.
- `files.workflows.<name>` and `files.actions.<name>` — generate GitHub workflow and composite-action files.

**Data flow.** Module files declare options → aggregates compose them → `configurations.<hostname>` builds a `nixosConfiguration` → `just switch` regenerates the generated files and runs `nh os switch`.

**Secrets.** One sops-encrypted file, `secrets/secrets.yaml` (`.sops.yaml` holds the age rules; age keys are derived from SSH keys persisted via impermanence). Modules reference secrets with `sops.secrets."<path>"` and build env files with `sops.templates."<name>"` (see `modules/flake/sops-nix.nix`).

**Generated files** (`flake.nix`, `flake.lock`, `README.md`, `justfile` + `*.just`, `.gitignore`, `.envrc`, `LICENSE`, `.github/workflows/*.yaml`, `.github/actions/*/action.yaml`) are produced by `just generate` from module options — never hand-edit them; change the generating module instead. `.pre-commit-config.yaml` is also generated (gitignored; hooks are configured in-flake).

## Key Directories

- `modules/programs/` — one file per program: `modules/programs/<name>.nix` (e.g. `eza.nix`, `ripgrep.nix`, `wakatime.nix`); a directory `modules/programs/<name>/` with `default.nix` once a second file is needed (`git/`, `fish/`, `nixvim/`, `comma/`).
- `modules/programs/ai/` — AI harnesses (`herdr/`, `harnesses/{omp,crush,prime-agent,pi-coding-agent,opencode2}/`), shared agent skills (`programs.agents.skills`, backed by the `mattpocock-skills` input), and `mcp.nix` (shared MCP servers).
- `modules/services/` — all services, one file each; each file declares its own level (NixOS and/or Home Manager), e.g. `printing.nix` (NixOS), `udisks.nix` (both).
- `modules/systems/` — host-side: `bases/`, `configurations/`, `users/`, `ssh/` (daemon: openssh, fail2ban, key persistence), `gui/` (hyprland, stylix, fonts, xdg), `hardware/`, `disk/` (impermanence), `nix/`, `boot/`, `locale/`.
- `modules/flake/` — flake-level machinery: `treefmt.nix`, `files/` (generated files: justfile, readme, gitignore, license), `packages/`, `pre-commit/`, `dev-shell.nix`, `settings.nix`, `nixpkgs.nix`, `sops-nix.nix`, `substituters.nix`.
- `secrets/` — the sops file; `.sops.yaml` at the root holds the age recipients and creation rules.

## Development Commands

The dev shell (loaded by direnv) provides `just`, `nh`, `sops`, `nil`, `prek`. Prefer `just` over raw `nix` commands wherever a recipe exists — recipes fill in the host name, the user name, and the generated files, and each documents itself.

```sh
just add                    # git add -AN — make new files visible to Nix
just eval <tree> <option>   # evaluate one option (trees: nixos, hm, flake, perSystem)
just docs <tree> <option>   # render the option's markdown docs
just inspect <tree> <option> <cmd>  # build a path, run a command in its output dir
just build <tree> <option>  # build a path without linking result
just switch | boot | test   # regenerate files, then nh os <action>
just fmt                    # nix fmt (treefmt)
prek                        # run the pre-commit hooks
just update-packages        # run each package's passthru.updateScript
just update                 # nix flake update + update-packages
```

**Work eval-first**: verify every change by evaluation, keep the rebuild for the end. After editing a module: `just add` (if you created a file), then `just eval system` — full configuration evaluation, builds nothing, about 35 seconds. Apply with `just switch`.

Reading `just eval` output: judge the output text, not the exit code — an inline `«error: ...»` marks one broken option and the command still exits 0. Ignore `trace: Obsolete option ...` lines from nixpkgs/Home Manager renames unless the name is one this repository sets. `--raw` prints one text option, `--json` stops at the first broken option.

## Code Conventions & Common Patterns

- **One file per program**, named for the feature it holds. Fragments inside a program directory are named by role — `options.nix`, `package.nix`, `stylix.nix`, `herdr.nix`, a bare `SKILL.md` — or by feature, like `git/signing.nix`, `fish/prompt.nix`, `nixvim/lsp.nix`. `modules/programs/comma/default.nix` is the canonical example: it uses every cross-cutting aggregate.
- **Client-side config in `programs/`, host-side daemons in `systems/`** — SSH: client known hosts in `programs/ssh.nix`, daemon in `systems/ssh/`. A user-facing app needing an activation hook is a program, not a service.
- **Services** all live in `modules/services/`; each file declares its own level.
- **`self'` and `inputs'` are ordinary module arguments** in NixOS and Home Manager modules (wired by `modules/systems/nix/per-system-args.nix`) — use them in place of `withSystem`.
- **Packages**: define in `perSystem.packages.<name>`, usually in a `package.nix` beside the module. `meta.description` is required — the README package table reads it. Add `passthru.updateScript` to include the package in `just update-packages`.
- **Secrets**: `sops.secrets."<path>" = { };`, then use `config.sops.secrets."<path>".path`; for env files use `sops.templates."<name>"` with `config.sops.placeholder."<path>"` (see `modules/services/network.nix`).
- **Comments**: only what the code cannot say — the non-obvious why — one line, plain words.
- **Writing**: always lowercase — comments, commit subjects and descriptions, CI job and step names, workflow names. Preserve capitalization in user-facing templates when an external format requires it. Keep identifiers and `${{ }}` expressions verbatim; backtick any code reference in prose.
- **Commits**: commit after every change — a finished unit of work is committed immediately, never left uncommitted. Conventional Commits (`type(scope): subject`), subject always lowercase.
- **Formatting**: treefmt with `on-unmatched = "fatal"` (nixfmt, statix, deadnix, shfmt, shellcheck, stylua, actionlint, ruff, oxfmt, xmllint, keep-sorted). A new file type needs a formatter entry in `modules/flake/treefmt.nix`, or `just fmt` fails.

## Important Files

- `flake.nix`, `flake.lock` — generated; inputs come from `flake-file.inputs.<name>.url` declarations in modules.
- `modules/systems/configurations/default.nix` — the `configurations.<hostname>` option: builds `nixosConfigurations`, user accounts, Home Manager wiring, `knownHosts`.
- `modules/systems/configurations/vidhan-pc/default.nix`, `modules/systems/configurations/vidhan-macbook/default.nix` — the host definitions (import a base, hardware, monitors, `system.stateVersion`).
- `modules/systems/bases/desktop/default.nix`, `modules/systems/bases/macbook/default.nix` — the base aggregates.
- `modules/systems/users/default.nix` — the `users.<username>` option tree.
- `modules/flake/files/justfile/default.nix` — generator for the justfile recipes (eval/build/inspect/docs trees).
- `modules/flake/files/readme/options.nix` — README section tree (`files.readme.content.<section>.content`).
- `modules/flake/treefmt.nix` — formatter set and excludes.
- `modules/flake/sops-nix.nix`, `secrets/secrets.yaml`, `.sops.yaml` — secrets wiring.
- `modules/programs/comma/default.nix` — the pattern reference for a complete program module.

## Runtime/Tooling Preferences

- Nix flakes with `nix-command` and `flakes` experimental features; nixpkgs `nixos-unstable` with `allowUnfree = true`.
- Import-from-derivation is off: `allow-import-from-derivation = false` (in the generated `nixConfig`) — evaluation fails if a module reads a build output.
- direnv + the flake dev shell: `just`, `nh`, `sops`, `nil`, `prek`, `nix-output-monitor`, `git`.
- `nh` drives system actions (`nh os switch`); `just` is the command surface.
- Generated files are regenerated by `just generate` (also a pre-commit hook) — never edit them by hand; change the module that declares them.

## Testing & QA

- **No unit or integration tests exist** (no `checks`, no test files). Verification is eval-first: `just eval system`, then `just build <path>`, then `just test` (`nh os test`) for the real thing.
- **Pre-commit** (run via `prek`, configured in `modules/flake/pre-commit/`): `generate-files` (regenerates project files), `treefmt` (`just fmt --ci`), `conventional-pre-commit` (`--strict`). Commit messages must be Conventional Commits: `type: description`.
- **CI** (workflows generated from `modules/flake/files/workflows/`): evaluates both `nixosConfigurations` (`toplevel.drvPath`, no builds), builds every `perSystem.packages.*`, checks formatting (`just fmt --ci`) and generated files (`just generate` + `git diff`). Uses `cachix/install-nix-action` (no DeterminateSystems actions, no caching); jobs need `FONTS_SSH_KEY` for the private `vidhan-fonts` input. The package update and Dependabot sync workflows need a `PACKAGE_UPDATE_TOKEN` secret with contents and pull-request write access; configure it as both an Actions and Dependabot secret so generated PRs trigger CI and can be updated safely. Dependabot (`.github/dependabot.yml`) opens daily PRs for the `nix` and `github-actions` ecosystems; dependabot-triggered runs get no Actions secrets, so dependabot PRs need a matching Dependabot secret named `FONTS_SSH_KEY`. `treefmt` `on-unmatched = "fatal"` means a file matching no formatter fails CI.
