set no-cd

hmConfig := nixosConfig + ".home-manager.users." + user
host := `hostname`
nixosConfig := ".#nixosConfigurations." + host + ".config"
perSystemConfig := ".#allSystems." + system + ".config"
system := `nix eval --raw --impure --expr 'builtins.currentSystem'`
systemPackage := nixosConfig + ".system.build.toplevel"
user := `whoami`

# List the available recipes
@default:
    just --list

# Record the intent to add each new file
[private]
@add:
    git add -AN

# Regenerate the generated files
@generate: add
    nix run .#generate-files

# Regenerate the files, then run `nh os` with the given action and flags
@os action *flags: generate
    if [ -t 1 ]; then nh os {{ action }} {{ flags }} .; else nh os {{ action }} --no-nom {{ flags }} .; fi

# Activate the configuration now, passing extra flags to `nh os`
@switch *flags: (os "switch" flags)

# Activate the configuration at the next boot, passing extra flags to `nh os`
@boot *flags: (os "boot" flags)

# Test the configuration, passing extra flags to `nh os`
@test *flags: (os "test" flags)

# Format the tree with treefmt, e.g. `just fmt --ci`
@fmt *flags: add
    nix fmt -- {{ flags }}

# Run the update script of each package that has one
@update-packages *packages: add
    nix run .#update-packages -- {{ packages }}

# Update the flake inputs, then update each package
update: generate
    nix flake update
    just generate
    just update-packages

# Evaluate a path under the current host's NixOS config, e.g. `just eval-nixos services.tailscale`
@eval-nixos option *flags: add
    nix eval {{ flags }} {{ nixosConfig }}.{{ option }}

# Evaluate a Home Manager option, e.g. `just eval-hm programs.git`
@eval-hm option *flags: add
    nix eval {{ flags }} {{ hmConfig }}.{{ option }}

# Evaluate a flake option's value, e.g. `just eval-flake files.generatedMessage.text`
@eval-flake option *flags: add
    nix eval {{ flags }} .#debug.config.{{ option }}

# Evaluate a per-system option's value, e.g. `just eval-per-system files.readme.rendered`
@eval-per-system option *flags: add
    nix eval {{ flags }} {{ perSystemConfig }}.{{ option }}

# Evaluate the whole configuration
@eval-system: fmt
    nix eval --raw {{ systemPackage }}.drvPath

# Build a flake path (or a Nix build expression) and print its output store paths
@build-flake *args: add
    if [ -t 1 ]; then nom build --no-link --print-out-paths {{ args }}; else nix build --no-link --print-out-paths {{ args }}; fi

# Build a NixOS config path, e.g. `just build-nixos system.build.toplevel`
@build-nixos option *flags: (build-flake (nixosConfig + "." + option) flags)

# Build a Home Manager config path, e.g. `just build-hm home.path`
@build-hm option *flags: (build-flake (hmConfig + "." + option) flags)

# Build a per-system config path, e.g. `just build-per-system packages.generate-files`
@build-per-system option *flags: (build-flake (perSystemConfig + "." + option) flags)

# Build the whole configuration
@build-system: (build-flake systemPackage)
