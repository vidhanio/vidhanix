---
name: generated-files
description: regenerate and verify repository outputs after changing a generator source or generated file.
disable-model-invocation: true
---

# generated files

1. If a generated output was edited, locate its source under `modules/flake/files/`; otherwise continue with the source change.
2. If the source is new, run `just add` before evaluation.
3. Run `just generate`, inspect the diff, and keep only changes caused by the source edit.
4. Run `just fmt --ci` and `just eval system`.
5. If generation changes an unexpected output, stop and trace the source before committing.
6. If generation is stable, run `git diff --check` and commit the source and intended outputs together.

Completion gates:

- [ ] `just generate` passes.
- [ ] generated outputs are reviewed and intentional.
- [ ] `just fmt --ci` and `just eval system` pass.
- [ ] `git diff --check` passes.
