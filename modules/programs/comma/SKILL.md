---
name: comma
description: Run a program from nixpkgs that is not installed, with comma. Use when a shell command fails with "command not found", or when a task needs a CLI tool that is absent from PATH.
---

# Run missing commands with comma

`comma` runs any program from nixpkgs for one command, without installation. The nix-index database is local on this machine, so the search for a program is immediate.

## Steps

1. Run the program through comma:

   ```sh
   comma <cmd> <args>
   ```

   The first run of a program downloads it from the binary cache. Allow extra time for large programs.

2. Read the result:
   - The program runs. The task continues.
   - The output is `Failed to open tty`. More than one package supplies `<cmd>`, and comma opened an interactive picker. Go to step 3.
   - The output is `No executable <cmd> found in nix-index database`. The program is unfree, or nixpkgs has no such program. Go to "Unfree programs".

3. List the packages that supply the command:

   ```sh
   comma -p <cmd>
   ```

4. Select the correct package from the list. Remove the `.out` suffix. Run the program through `nix shell`:

   ```sh
   nix shell nixpkgs#<package> --command <cmd> <args>
   ```

## Unfree programs

The nix-index database holds free packages only. comma finds no unfree program, and it reports `No executable <cmd> found in nix-index database` for `op`, `spotify`, and other unfree programs.

1. Give the attribute name of the package to `nix eval`, to confirm that the package exists:

   ```sh
   nix eval --raw nixpkgs#<attr>.meta.description
   ```

   The attribute name of a package is not always equal to the name of the program. Example: the program `op` is in the attribute `_1password-cli`.

2. Run the program from the unfree nixpkgs flake:

   ```sh
   nix shell github:numtide/nixpkgs-unfree/nixos-unstable#<attr> --command <cmd> <args>
   ```

The flake `github:numtide/nixpkgs-unfree` is nixpkgs with `allowUnfree` set to true. Plain `nixpkgs#<attr>` gives the error `Refusing to evaluate package ... because it has an unfree license`.

## More comma commands

- `comma man <cmd>` shows the man page of a program.
- `comma -x <cmd>` prints the absolute store path of the executable, and runs nothing. Use it when a different program needs the path.

## Limits

- comma makes no permanent change. It runs the program for one command only.
- To make a tool permanent, add the package to the Nix configuration of the current repository. Ask the user first.
- Leave `comma -i` (install) and `comma -s` (shell) to the user. Both commands change the environment of the user.
