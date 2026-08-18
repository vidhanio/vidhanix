# Development Playbook

## Cycle

Work eval-first. Inspect the relevant module and its callers, make the smallest change, then run:

```sh
just add
just generate
just fmt --ci
just eval-system
```

Use `just eval-nixos <option>` and the other `eval-*` recipes for focused values, `just build-nixos <option>` and the other `build-*` recipes for relevant builds, and `prek` for repository checks. Use `nix flake check --no-build` when validating the complete flake. Read command output for inline `«error: ...»` values; a successful exit status alone is not enough.

Run generation before reviewing a diff. Finish with both host evaluations and relevant builds when a change touches system or package configuration.

## Source of Truth

Generated files are outputs, not editing targets. Change their module source under `modules/flake/files/`, then run `just generate` and inspect the result. Keep generated output in the commit when it changes. Treat secrets and `.sops.yaml` as sensitive.

## Style

Write prose with standard capitalization. Keep commit titles, comments, and CLI errors lowercase. Preserve required code and protocol spelling, including Nix option names and GitHub expressions. Write short comments only for non-obvious reasons. Declare each aspect attribute path once per source file, co-locate its classes and providers within that file, and use an `imports` list inside that declaration for multiple implementation pieces. Keep separate implementation files separate instead of folding them into a default file. Never inline a class configuration: use `flake.aspects.<name> = { <class> = ...; };` instead of `flake.aspects.<name>.<class> = ...`, even when the class has only one setting. Omit module argument lists when no arguments are used instead of writing `_:`. Format with `just fmt --ci`; keep the configured formatter set passing.

Use conventional commits. Commit each finished unit of work promptly, with no unrelated changes. Leave no staged or unstaged work after a finished unit.

## Safety

Preserve infrastructure behavior by default. Before changing boot, disks, persistence, networking, secrets, SSH, hosts, services, or CI, inspect dependencies and compare the relevant evaluated options. Ask for approval before an infrastructure-impacting behavior change that is not explicitly requested. Never hide an evaluation error or weaken a safety check to make validation pass.

## Interface Map

- `flake.aspects` defines the feature and profile graph; resolved modules are consumed through `inputs.self.modules`.
- `hosts` registers hosts and produces NixOS configurations.
- `users` registers identities and complete Home Manager aspects.
- Generator sources live under `modules/flake/files/`.
- Command entrypoints are the direct `justfile`, `just`, `nix`, and `prek`.
