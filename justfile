set no-cd

system := `nix eval --raw --impure --expr 'builtins.currentSystem'`
host := `hostname`
user := `whoami`

nixosConfig := ".#nixosConfigurations." + host + ".config"
hmConfig := nixosConfig + ".home-manager.users." + user
systemPackage := nixosConfig + ".system.build.toplevel"


# List the available recipes
@default:
    just --list

# Add each new file
@add:
    git add -A

# Regenerate the generated files
@generate: add
    nix run .#write-files

[private]
@run-deploy target *flags: add
    if [ -t 1 ]; then \
        set -o pipefail; \
        deploy --no-progress {{ target }} {{ flags }} -- --log-format internal-json -v 2>&1 | nom --json; \
    else \
        deploy {{ target }} {{ flags }}; \
    fi

# Deploy `host` with deploy-rs, e.g. `just host=voyager deploy --dry-activate`
@deploy *flags: (run-deploy (".#" + host) flags)

# Deploy every host, passing extra flags to `deploy`
@deploy-all *flags: (run-deploy "." flags)

# Activate the configuration now, passing extra flags to `deploy`
@switch *flags: (deploy flags)

# Activate the configuration at the next boot, passing extra flags to `deploy`
@boot *flags: (deploy "--boot" flags)

# Activate the configuration without adding a boot entry, passing extra flags to `deploy`
@test *flags: (deploy "--test" flags)

# Build the configuration, passing extra flags to `nix build`
@build *flags: add
    if [ -t 1 ]; then \
        nom build {{ systemPackage }} {{ flags }}; \
    else \
        nix build {{ systemPackage }} {{ flags }}; \
    fi

# Format the tree with treefmt, e.g. `just fmt --ci`
@fmt *flags: add
    nix fmt -- {{ flags }}

# Run the update script of each package that has one
@update-packages *packages: add
    nix run .#update-packages -- {{ packages }}

# Update the flake inputs, then update each package
update: add
    nix flake update
    just update-packages

# Evaluate a path under `host`'s NixOS config, e.g. `just eval-nixos services.tailscale`
@eval-nixos option *flags: add
    nix eval {{ flags }} {{ nixosConfig }}.{{ option }}

# Evaluate a Home Manager option, e.g. `just eval-hm programs.git`
@eval-hm option *flags: add
    nix eval {{ flags }} {{ hmConfig }}.{{ option }}
