---
name: infrastructure-change
description: review and validate a change that can affect hosts, boot, disks, persistence, networking, secrets, services, ssh, or CI.
disable-model-invocation: true
---

# infrastructure changes

1. if the change affects only user-space configuration, use the normal eval-first cycle; otherwise continue.
2. inspect callers, dependencies, secrets, and host selection before editing.
3. if the requested behavior is explicit, record the relevant before-and-after options; otherwise stop and obtain approval.
4. run focused evaluations for every affected host and option.
5. evaluate both toplevel derivations with `nix eval --raw .#nixosConfigurations.vidhan-pc.config.system.build.toplevel.drvPath` and the equivalent `vidhan-macbook` command.
6. run affected builds; if the current platform cannot build one, record the limitation and run `nix flake check --no-build`.
7. if an option is missing, errors, or changes outside the request, restore the narrow scope; otherwise run `prek` and `git diff --check`.

completion gates:

- [ ] scope, before-and-after behavior, and required approvals are recorded.
- [ ] focused evaluations and both host evaluations pass without inline errors.
- [ ] affected builds pass or an explicit platform limitation is recorded.
- [ ] `prek`, `nix flake check --no-build`, and `git diff --check` pass.
