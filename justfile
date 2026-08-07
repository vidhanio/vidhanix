host := `hostname`
user := `whoami`

# list the available recipes
default:
    @just --list

# record the intent to add each new file, so that the flake sees it
@add:
    git add -AN

# regenerate the generated files
@generate: add
    nix run .#generate-files

# regenerate the files, then run `nh os` with the given action
@os action="switch": generate
    nh os {{ action }}

# activate the configuration now
switch: (os "switch")

# activate the configuration at the next boot
boot: (os "boot")

# activate the configuration without making it the boot default
test: (os "test")

# format the tree with treefmt, e.g. `just fmt --ci`
@fmt *flags: add
    nix fmt -- {{ flags }}

# run the update script of each package that has one
@update-packages *packages: generate
    nix run .#update-packages -- {{ packages }}

# update the flake inputs, then update each package
update: generate
    nix flake update
    nix run .#update-packages

# evaluate a nixos option, e.g. `just eval-nixos services.printing`
@eval-nixos option *flags: add
    nix eval {{ flags }} .#nixosConfigurations.{{ host }}.config.{{ option }}

# evaluate a home manager option, e.g. `just eval-hm programs.git`
@eval-hm option *flags: add
    nix eval {{ flags }} .#nixosConfigurations.{{ host }}.config.home-manager.users.{{ user }}.{{ option }}

# evaluate the whole configuration, and build nothing
@eval-system: add
    nix eval --raw .#nixosConfigurations.{{ host }}.config.system.build.toplevel.drvPath

# build a flake path and run a command in its output directory, e.g. `just inspect .#muvm-steam ls -la`
@inspect path +args: add
    nix build {{ path }} --no-link --print-out-paths | while read -r out; do cd "$out" && {{ args }}; done

# build a nixos config path and run a command in its output directory, e.g. `just inspect-nixos system.build.toplevel ls`
@inspect-nixos option +args: add
    nix build .#nixosConfigurations.{{ host }}.config.{{ option }} --no-link --print-out-paths | while read -r out; do cd "$out" && {{ args }}; done

# build a home manager config path and run a command in its output directory, e.g. `just inspect-hm home.path ls`
@inspect-hm option +args: add
    nix build .#nixosConfigurations.{{ host }}.config.home-manager.users.{{ user }}.{{ option }} --no-link --print-out-paths | while read -r out; do cd "$out" && {{ args }}; done
