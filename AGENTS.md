# AGENTS.md

Guidance for coding agents working in this NixOS configuration repository.

## Project Overview

NixOS configuration flake (vidhanix) using the dendritic pattern with `flake-parts` and `import-tree`. All modules in `./modules/` are automatically imported. Configurations for:

- **vidhan-pc** (x86_64-linux) - Desktop PC
- **vidhan-macbook** (aarch64-linux) - Apple Silicon MacBook

## Commands

```bash
direnv allow                         # Enter development shell
rebuild                              # Rebuild and switch (equivalent to `nh os switch`)
rebuild boot                         # Build and set as boot entry without switching
rebuild test                         # Test build without switching
nix fmt                              # Format all code (runs via pre-commit hook)
treefmt --fail-on-change             # Check formatting without modifying
nix run .#update-packages            # Update all packages with update scripts
nix run .#update-packages <package>  # Update specific package
nix run .#generate-files             # Generate flake.nix, README.md, .gitignore, .envrc, LICENSE
agenix -e secrets/<secret>.age       # Edit encrypted secrets
```

## Architecture

### Module System

All configuration lives in `modules/`. The `import-tree` flake automatically imports every `.nix` file:

1. **Flake outputs** - Use `perSystem`, `packages`, `devShells`
2. **NixOS modules** - Define in `flake.modules.nixos.<name>`
3. **Home Manager modules** - Define in `flake.modules.homeManager.<name>`
4. **Configurations** - Use `config.configurations.<hostname>` (auto-becomes `nixosConfigurations`)

### Configuration Definition

```nix
configurations.<hostname> = {
  users = [ "vidhanio" ];           # Required: list of users
  publicKey = "ssh-ed25519 ...";    # Required: SSH public key
  module = { ... };                  # NixOS module
  homeModule = { ... };              # Home Manager module
};
```

### Module Categories

- **flake/** - Meta/repo infrastructure: dev shell, package updates, substituters, treefmt, generated files, agenix, pre-commit
- **programs/** - All application configs (both NixOS and Home Manager)
- **services/** - High-level user-facing services (printing, wakatime, sunshine)
- **systems/bases/** - Desktop/macbook base NixOS modules (`nixos.desktop`, `nixos.macbook`)
- **systems/boot/** - Boot loader and binfmt config
- **systems/configurations/** - Per-host NixOS configurations (`vidhan-pc`, `vidhan-macbook`)
- **systems/disk/** - Disk layout, impermanence, swap
- **systems/gui/** - GUI stack: Hyprland, Waybar, Stylix, fonts, audio, cursor, greeter, lock
- **systems/hardware/** - Hardware-specific config (Bluetooth, fwupd, Logitech, Xbox controller)
- **systems/locale/** - Timezone and i18n settings
- **systems/nix/** - All `nix.settings` config plus flake registry
- **systems/services/** - Low-level system services (network, tailscale, tuned, udisks, upower)
- **systems/ssh/** - SSH server config and key persistence
- **systems/sudo/** - sudo policy
- **systems/users/** - User definitions

### Generated Files

`flake.nix`, `README.md`, `.gitignore`, `.envrc`, and `LICENSE` are auto-generated. Do not edit directly.

## Code Style

### Formatting Tools (modules/treefmt.nix)

- **nixfmt** - Nix formatting
- **statix** - Nix linting
- **deadnix** - Dead code detection
- **shfmt** - Shell formatting
- **shellcheck** - Shell linting
- **actionlint** - GitHub Actions linting
- **oxfmt** - Ox formatting
- **xmllint** - XML formatting
- **keep-sorted** - List sorting

Pre-commit hooks run `treefmt --fail-on-change` and `generate-files` automatically.

### Nix Style Guidelines

**Function arguments** - List dependencies, then `{ ... }:`:

```nix
{ inputs, lib, config, ... }:
{
  # module body
}
```

**With patterns** - Use at function argument level:

```nix
{ withSystem, inputs, ... }:
{ /* ... */ }
```

**Let bindings** - Place at top of module/function:

```nix
{ config, ... }:
let
  cfg = config.programs.myapp;
in
{ /* ... */ }
```

**Option definitions** - Use `lib.mkOption`:

```nix
options.myFeature = lib.mkOption {
  type = lib.types.str;
  description = "Description here";
  default = "default-value";
};
```

**Enable patterns** - Use `lib.mkEnableOption`:

```nix
options.programs.myapp.enable = lib.mkEnableOption "MyApp";
```

**Conditional config** - Use `lib.mkIf`:

```nix
config = lib.mkIf cfg.enable {
  home.packages = [ cfg.package ];
};
```

**Flake modules** - Contribute to `flake.modules`:

```nix
flake.modules = {
  nixos.default = { config, ... }: { /* NixOS config */ };
  homeManager.default = { config, ... }: { /* Home Manager config */ };
};
```

**Package definitions** - Define in `perSystem.packages`:

```nix
perSystem = { pkgs, ... }: {
  packages.myapp = pkgs.callPackage ./package.nix { };
};
```

**With update scripts** - Add `passthru.updateScript`:

```nix
passthru.updateScript = nix-update-script { };
```

### Import Patterns

**Inputs** - Reference flake inputs in module args:

```nix
{ inputs, ... }:
{
  flake-file.inputs.my-input.url = "github:owner/repo";
  imports = [ inputs.some-flake.flakeModules.default ];
}
```

**Relative paths** - Use for local references:

```nix
age.secrets.password.file = ../../secrets/password.age;
```

### Naming Conventions

- **Files**: kebab-case (e.g., `my-feature.nix`)
- **Options**: camelCase (e.g., `home.packages`)
- **Configurations**: Hostname matches machine (e.g., `vidhan-pc`)
- **Packages**: kebab-case (e.g., `helium-bin`)
- **Modules**: Descriptive names (e.g., `nixos.default`, `homeManager.default`)

### Persistence

Use the `persist` option for directories/files that should survive reboots:

```nix
persist.directories = [ ".config/app" ];
persist.files = [ ".config/app/config.json" ];
```

### Secrets

Uses agenix. Define in `secrets.nix`:

```nix
"secrets/my-secret.age".publicKeys = all;
```

Reference in modules:

```nix
age.secrets.my-secret.file = ../../secrets/my-secret.age;
```

## Commit Conventions

Uses `conventional-pre-commit`. Format: `type(scope): description`

Examples: `feat(hyprland): add window rules`, `fix(git): correct signing key path`, `chore: update flake inputs`

## Common Tasks

**Adding a new program**:

1. Create `modules/programs/<name>/default.nix`
2. Add Home Manager config in `flake.modules.homeManager.default`
3. Add persistence if needed with `persist.directories`

**Adding a package**:

1. Create `modules/<category>/<name>/package.nix`
2. Define in `perSystem.packages`
3. Add `passthru.updateScript` if applicable

**Adding a secret**:

1. Run `agenix -e secrets/<name>.age`
2. Add to `secrets.nix` with appropriate public keys
3. Reference in module with `age.secrets.<name>.file`
