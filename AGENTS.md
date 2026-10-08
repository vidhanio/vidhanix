# `AGENTS.md`

Personal NixOS and Home Manager configurations, composed with flake-parts and import-tree using the Dendritic pattern.

## Organization

- `modules/profiles/`: shared NixOS and Home Manager configuration. `base` provides headless foundations; `pc` extends it for desktop systems; `apple-silicon` extends `pc` for Apple hardware.
- `modules/hosts/<hostname>/`: host metadata, profile selection, and machine-specific configuration.
- `modules/users/<username>/`: user identity and Home Manager configuration.
- `modules/system/`: boot, storage, persistence, and Nix configuration.
- `modules/desktop/`: shared bindings, workspaces, appearance, and session helpers.
- `modules/programs/<name>/`: application and compositor configuration, adapters, and packages.
- `modules/services/<name>/`: service configuration.
- `modules/upstream/_modules/{nixos,home-manager,stylix}/`: reusable modules in upstream-compatible layouts.
- `modules/flake/`: inputs, tooling, generated files, and repository infrastructure.

## Module conventions

- Follow the conventions of the feature being changed. Keep related configuration, packages, and assets together.
- The `import-tree` loader discovers Nix files under `modules/` automatically. Underscore-prefixed paths are excluded from discovery.
- Contribute shared configuration to `profiles.<name>.module` for NixOS and `profiles.<name>.homeModule` for Home Manager. Profile inheritance imports both module classes explicitly.
- Contribute host configuration to `hosts.<hostname>.{module,homeModule}` and per-user Home Manager configuration to `users.<username>.module`.
- Prefer upstream NixOS and Home Manager options. Use `home.packages` for packages requiring no additional configuration.
- Reusable modules define NixOS or Home Manager options and implementation. The base profile imports the `nixosModules.upstream` and `homeModules.upstream` bundles. Keep personal preferences in feature modules.
- Stylix targets follow the upstream target layout and use its `mkTarget` implementation.
- Group related settings in cohesive files. Keep option declarations in `options.nix` when a feature benefits from a separate schema.
- Use `lib.getExe` for a package's main executable and `lib.getExe'` for secondary commands.
- Preserve ordering in sorted blocks. Add concise comments where the rationale needs explanation.

## Workflow

- Load the development shell with `direnv reload`.
- Check the working tree before running recipes that stage files with `git add -A`.
- Stage new files before flake evaluation.
- Edit the Nix definitions for generated files and regenerate with `just generate`.
- Format with `nix fmt` and validate affected configurations through evaluation or builds.
- Activate configurations only when explicitly requested.
- Commit completed work with a lowercase `<scope>: <description>` title, such as `kitty: disable close confirmation`.
- Fold small follow-ups into the current commit. Keep unrelated changes separate and leave completed task changes committed.
