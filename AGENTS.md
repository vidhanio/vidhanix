# development playbook

## cycle

Work eval-first. Inspect the relevant module and its callers, make the smallest change, then run:

```sh
just add
just generate
just fmt --ci
just eval system
```

Use `just eval <tree> <option>` for a focused value, `just build <tree> <option>` for a relevant build, and `prek` for repository checks. Use `nix flake check --no-build` when validating the complete flake. Read command output for inline `«error: ...»` values; a successful exit status alone is not enough.

Run generation before reviewing a diff. Finish with both host evaluations and relevant builds when a change touches system or package configuration.

## source of truth

Generated files are outputs, not editing targets. Change their module source under `modules/flake/files/`, then run `just generate` and inspect the result. Keep generated output in the commit when it changes. Treat secrets and `.sops.yaml` as sensitive.

## style

Keep prose, comments, identifiers exposed to users, and commit subjects lowercase unless an external format requires otherwise. Preserve required code and protocol spelling, including Nix option names and GitHub expressions. Write short comments only for non-obvious reasons. Format with `just fmt --ci`; keep the configured formatter set passing.

Use conventional commits. Commit each finished unit of work promptly, with no unrelated changes. Leave no staged or unstaged work after a finished unit.

## safety

Preserve infrastructure behavior by default. Before changing boot, disks, persistence, networking, secrets, ssh, hosts, services, or CI, inspect dependencies and compare the relevant evaluated options. Ask for approval before an infrastructure-impacting behavior change that is not explicitly requested. Never hide an evaluation error or weaken a safety check to make validation pass.

## interface map

- `flake.aspects` defines the feature and profile graph; resolved modules are consumed through `inputs.self.modules`.
- `configurations` registers hosts and produces NixOS configurations.
- `users` registers identities and complete Home Manager aspects.
- generator sources live under `modules/flake/files/`.
- command entrypoints are the generated `justfile`, `just`, `nix`, and `prek`.
