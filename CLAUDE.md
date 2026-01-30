# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a NixOS configuration flake (vidhanix) that manages system configurations for two machines:

- **vidhan-pc** (x86_64-linux) - Desktop PC
- **vidhan-macbook** (aarch64-linux) - Apple Silicon MacBook

The flake uses `flake-parts` with `import-tree` to automatically import all modules from `./modules/`.

## Commands

```bash
# Enter development shell (via direnv)
direnv allow

# Rebuild and switch to new system configuration
rebuild              # equivalent to `nh os switch`
rebuild boot         # build and set as boot entry without switching
rebuild test         # test build without switching

# Format all code (runs via pre-commit hook automatically)
nix fmt

# Update all packages with update scripts
nix run .#update-packages
nix run .#update-packages <package>   # update specific package

# Generate repository files (README.md, .gitignore, LICENSE, .envrc, flake.nix)
nix run .#generate-files

# Edit encrypted secrets
agenix -e secrets/<secret>.age
```

## Architecture

### Module System

All configuration lives in `modules/`. The `import-tree` flake automatically imports every `.nix` file in `modules/`.

**Key module pattern** - modules can contribute to:

- Flake outputs (packages, devShells, etc.)
- `nixosConfigurations` via `config.configurations.<name>`
- Home Manager modules via `config.configurations.<name>.homeModule`

### Configuration Definition (`modules/configurations/`)

System configurations are defined with:

```nix
configurations.<hostname> = {
  module = { ... };      # NixOS module
  homeModule = { ... };  # Home Manager module
};
```

These automatically become `flake.nixosConfigurations.<hostname>`.

### Notable Module Categories

- **bases/** - Base configs (desktop environment, macbook-specific with nixos-apple-silicon)
- **desktop/hyprland/** - Hyprland compositor, hyprlock, hypridle
- **disk/impermanence/** - Ephemeral root filesystem with impermanence
- **fonts/packages/** - Custom font packages (berkeley-mono, google-sans-flex, pragmata-pro)
- **nix/flake/** - Dev shell, package update scripts, substituters
- **programs/** - Application configs (1password, git, vscode)

### Generated Files

`flake.nix` and several other files are auto-generated. Do not edit them directly - modify the source in `modules/files/` and run `nix run .#generate-files`.

### Code Formatting

Treefmt is configured with: nixfmt, statix, deadnix, shfmt, shellcheck, actionlint, oxfmt, xmllint, keep-sorted.

Pre-commit hooks run `treefmt` and `generate-files` automatically.

### Secrets Management

Uses agenix with age-encrypted files in `secrets/`. Keys are configured in `secrets.nix`.
