# AGENTS.md

This is my dendritic NixOS flake for system preferences, programs, and configurations across my machines.

## Structure

- Look for an existing feature under `modules/` and follow nearby patterns.
- Files under `modules/` are imported automatically as flake-parts modules, except underscore-prefixed paths. Contribute directly to `profiles.<name>.module` (NixOS) and `profiles.<name>.homeModule` (Home Manager); do not create per-feature module registries.
- Prefer upstream Home Manager options for user configuration and NixOS options for system-level features. Packages alone can go in `home.packages`.
- Keep apps and compositor-specific settings in `modules/programs/<name>/`, services in `modules/services/<name>/`, shared desktop configuration in `modules/desktop/`, and system foundations in the shallow `modules/system/` directory. Avoid generic `settings/` layers and one-option feature directories; keep related settings together and assets beside their owner.
- Profiles live in `modules/profiles/`. Use `profiles.base` for headless systems, `profiles.pc` for personal computers, and `profiles.apple-silicon` for Apple-specific settings. Profiles inherit both module classes explicitly.
- Keep machine-specific settings in `modules/hosts/<hostname>/` contributing to `hosts.<hostname>.{module,homeModule}`, and identities and per-user Home Manager settings in `modules/users/<username>/` contributing to `users.<username>.module`.
- Put reusable NixOS, Home Manager, and Stylix implementations in `modules/upstream/_modules/{nixos,home-manager,stylix}` using upstream layouts. These are ordinary lower-level modules, not flake-parts modules; the base profile imports the exported upstream bundles. Keep personal configuration outside them.
- Repository-specific option helpers may stay in `options.nix` contributing directly to a profile. Keep sorted blocks sorted.
- Edit the Nix sources of generated files, not their generated output; regenerate with `just generate`.

## Workflow

- Load the dev shell with `direnv reload`.
- Use `just` recipes where helpful
- Stage new files before Nix evaluation so the flake can see them. Some recipes run `git add -A`, so check for unrelated changes first.
- Format with `nix fmt` and validate the affected configuration with an appropriate evaluation or build. Do not activate the system unless asked.
- Add comments only when necessary, and keep them concise.
- Commit each finished unit of work with a lowercase `<scope>: <description>` title, e.g. `kitty: disable close confirmation`.
- Fold small follow-ups into the current unit's commit. Leave no task changes uncommitted, and do not include unrelated changes.
