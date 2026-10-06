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

# Regenerate the generated files, bring flake.lock up to date, and remove duplicate inputs
@generate: add
    nix run .#generate-files

# Regenerate the files, then run `nh os` with the given action and flags
@os action *flags: generate
    if [ -t 1 ]; \
        then nh os {{ action }} {{ flags }} .; \
    else \
        nh os {{ action }} --no-nom {{ flags }} .; \
    fi

# Activate the configuration now, passing extra flags to `nh os`
@switch *flags: (os "switch" flags)

# Activate the configuration at the next boot, passing extra flags to `nh os`
@boot *flags: (os "boot" flags)

# Test the configuration, passing extra flags to `nh os`
@test *flags: (os "test" flags)

# Build the configuration, passing extra flags to `nh os`
@build *flags: (os "build" flags)

# Format the tree with treefmt, e.g. `just fmt --ci`
@fmt *flags: add
    nix fmt -- {{ flags }}

# Run the update script of each package that has one
@update-packages *packages: add
    nix run .#update-packages -- {{ packages }}

# Update the flake inputs, then update each package
update: generate
    nix flake update
    just update-packages

# Evaluate a path under the current host's NixOS config, e.g. `just eval-nixos services.tailscale`
@eval-nixos option *flags: add
    nix eval {{ flags }} {{ nixosConfig }}.{{ option }}

# Evaluate a Home Manager option, e.g. `just eval-hm programs.git`
@eval-hm option *flags: add
    nix eval {{ flags }} {{ hmConfig }}.{{ option }}
