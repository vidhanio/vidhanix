# development playbook

## cycle

work eval-first. inspect the relevant module and its callers, make the smallest change, then run:

```sh
just add
just generate
just fmt --ci
just eval system
```

use `just eval <tree> <option>` for a focused value, `just build <tree> <option>` for a relevant build, and `prek` for repository checks. use `nix flake check --no-build` when validating the complete flake. read command output for inline `«error: ...»` values; a successful exit status alone is not enough.

run generation before reviewing a diff. finish with both host evaluations and relevant builds when a change touches system or package configuration.

## source of truth

generated files are outputs, not editing targets. change their module source under `modules/flake/files/`, then run `just generate` and inspect the result. keep generated output in the commit when it changes. treat secrets and `.sops.yaml` as sensitive.

## style

keep prose, comments, identifiers exposed to users, and commit subjects lowercase unless an external format requires otherwise. preserve required code and protocol spelling, including Nix option names and GitHub expressions. write short comments only for non-obvious reasons. declare each aspect attribute path once per source file, co-locate its classes and providers within that file, and use an `imports` list inside that declaration for multiple implementation pieces. keep separate implementation files separate instead of folding them into a default file. never inline a class configuration: use `flake.aspects.<name> = { <class> = ...; };` instead of `flake.aspects.<name>.<class> = ...`, even when the class has only one setting. omit module argument lists when no arguments are used instead of writing `_:`. format with `just fmt --ci`; keep the configured formatter set passing.

use conventional commits. commit each finished unit of work promptly, with no unrelated changes. leave no staged or unstaged work after a finished unit.

## safety

preserve infrastructure behavior by default. before changing boot, disks, persistence, networking, secrets, ssh, hosts, services, or CI, inspect dependencies and compare the relevant evaluated options. ask for approval before an infrastructure-impacting behavior change that is not explicitly requested. never hide an evaluation error or weaken a safety check to make validation pass.

## interface map

- `flake.aspects` defines the feature and profile graph; resolved modules are consumed through `inputs.self.modules`.
- `configurations` registers hosts and produces NixOS configurations.
- `users` registers identities and complete Home Manager aspects.
- generator sources live under `modules/flake/files/`.
- command entrypoints are the generated `justfile`, `just`, `nix`, and `prek`.
