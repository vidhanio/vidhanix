---
name: adding-aspects
description: Add a program, service, or system feature to vidhanix as a flake aspect, including upstream-option discovery, local module creation, and profile inclusion.
---

# Adding Aspects

1. Search `modules/` for an existing aspect, then check upstream support with `just search-hm <option>` and `just search-nixos <option>`. Prefer Home Manager unless the feature must be system-level.
2. If an upstream module exists, use the simple form: create or update `modules/{programs,services,systems}/<name>/default.nix` and configure its options. A package-only feature may use `home.packages` instead.
3. If no upstream module exists, ask whether to configure the underlying files/packages directly or provide a reusable local module. For a local module, put option declarations and their implementation in `options.nix`; use `default.nix` to enable and configure those options for this system. Follow nearby `cfg`, `mkEnableOption`, `mkPackageOption`, and `mkIf` patterns.
4. Declare each class inside the aspect, for example `flake.aspects.<name> = { homeManager = ...; };`. Files under `modules/` merge automatically; never add imports. Declare new flake inputs as `flake-file.inputs.<name>` in the aspect that consumes them.
5. Add the aspect to `modules/systems/profiles/core/default.nix` when it is foundational or needed without a graphical session; otherwise add it to `modules/systems/profiles/gui/default.nix`. Keep the sorted block sorted.
6. Follow the repository development cycle, including a focused evaluation of the affected Home Manager or NixOS option.

More complex aspects may span classes or files. Keep one aspect name across them and copy the closest existing pattern rather than introducing another structure.
