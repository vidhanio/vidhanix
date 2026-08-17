---
name: infrastructure-change
description: review and validate a change that can affect hosts, boot, disks, persistence, networking, secrets, services, ssh, or CI.
disable-model-invocation: true
---

# infrastructure changes

1. Classify the change. If it affects only user-space configuration, use the normal eval-first cycle; otherwise continue with this procedure.
2. Inspect callers, dependencies, secrets, and host selection before editing.
3. If the requested behavior is explicit, record the relevant before-and-after options. If it is not explicit, pause and obtain approval before changing behavior.
4. Run focused evaluations for every affected host and option, then evaluate both complete hosts.
5. Build only the affected system or package paths; use `--no-build` checks when a build is unavailable on the current platform.
6. If any option is missing, errors, or changes outside the request, stop and restore the narrow scope.

Completion gates:

- [ ] scope and before/after behavior are recorded.
- [ ] approval exists for every unrequested infrastructure behavior change.
- [ ] focused evaluations and both host evaluations pass without inline errors.
- [ ] relevant builds or an explicit platform limitation are recorded.
- [ ] repository checks pass and the diff contains no unrelated infrastructure change.
