---
name: generated-files
description: Regenerate and verify repository outputs after changing a generator source or generated file.
disable-model-invocation: true
---

# Generated Files

1. If a generated output was edited, locate its source under `modules/flake/files/`; otherwise continue with the source change.
2. If the source is new, run `just add` before evaluation.
3. Run `just generate`, inspect the diff, and keep only changes caused by the source edit.
4. If generation changes an unexpected output, stop and trace the source; otherwise run `just fmt --ci` and `just eval-system`.
5. If the change affects system or package configuration, evaluate both host toplevel derivations and run the relevant builds.
6. Run `git diff --check` and commit the source with its intended outputs.

Completion Gates:

- [ ] `just generate` passes and intended outputs are reviewed.
- [ ] `just fmt --ci`, `just eval-system`, and `git diff --check` pass.
- [ ] Both hosts and relevant builds pass when system or package configuration changed.
