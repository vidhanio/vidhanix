---
name: infrastructure-change
description: Review and validate a change that can affect hosts, boot, disks, persistence, networking, secrets, services, SSH, or CI.
disable-model-invocation: true
---

# Infrastructure Changes

1. If the change affects only user-space configuration, use the normal eval-first cycle; otherwise continue.
2. Inspect callers, dependencies, secrets, and host selection before editing.
3. If the requested behavior is explicit, record the relevant before-and-after options; otherwise stop and obtain approval.
4. Run focused evaluations for every affected host and option.
5. Evaluate both toplevel derivations with `nix eval --raw .#nixosConfigurations.vortex.config.system.build.toplevel.drvPath` and the equivalent `voyager` command.
6. Run affected builds; if the current platform cannot build one, record the limitation and run `nix flake check --no-build`.
7. If an option is missing, errors, or changes outside the request, restore the narrow scope; otherwise run `prek` and `git diff --check`.

Completion Gates:

- [ ] Scope, before-and-after behavior, and required approvals are recorded.
- [ ] Focused evaluations and both host evaluations pass without inline errors.
- [ ] Affected builds pass or an explicit platform limitation is recorded.
- [ ] `prek`, `nix flake check --no-build`, and `git diff --check` pass.
